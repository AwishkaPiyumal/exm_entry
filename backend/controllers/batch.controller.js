import pool from "../config/db.js";
import errorProvider from "../utils/errorProvider.js";
import { parseString } from "../utils/functions.js";
import lodash from "lodash";

export const getAllBatches = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      // Call the stored procedure to get all batches
      const [batches] = await conn.query("CALL GetAllBatches()");

      if (!batches.length) {
        return next(errorProvider(404, "No batches found"));
      }

      const temp = batches[0].map((obj) => ({
        ...parseString(obj.batch_code),
        status: obj.status,
        batch_id: obj.batch_id,
      }));

      return res.status(200).json(temp);
    } catch (error) {
      console.error("Error retrieving batches:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving batches")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllBatchDetails = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL GetAllBatchDetails();");

      res.status(200).json(result[0]); // Return the first result set containing batch details
    } catch (error) {
      console.error("Error fetching batch details:", error);
      return next(
        errorProvider(500, "An error occurred while fetching batch details.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const getBatchById = async (req, res, next) => {
  const { batch_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      // Call the first stored procedure to get batch details
      const [batch] = await conn.query("CALL GetBatchDetails(?)", [batch_id]);

      if (!batch[0].length) {
        return next(errorProvider(404, "No Batches found"));
      }

      // Parse batch_code in Node.js
      const details = parseString(batch[0][0].batch_code);

      // Call the second stored procedure to get degree, department, and faculty details
      const [degFacDepResults] = await conn.query(
        "CALL GetDegFacDepDetails(?)",
        [details.degree_name_short]
      );

      // Fetch curriculum and lecturer details for the batch
      const [batCurLecResult] = await conn.query(
        "SELECT bcl.* FROM batch_curriculum_lecturer bcl INNER JOIN curriculum c ON bcl.sub_id = c.sub_id WHERE bcl.batch_id = ? AND c.status = 'true'",
        [batch_id]
      );

      // Transform curriculum and lecturer details into a key-value map
      const subjects = {};
      batCurLecResult.forEach((obj) => {
        subjects[obj.sub_id] = obj.m_id.toString();
      });

      return res.status(200).json({
        status: batch[0][0].status,
        ...details,
        ...degFacDepResults[0][0],
        subjects,
        batch_id,
      });
    } catch (error) {
      console.error("Error retrieving batch:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving batch")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const createBatch = async (req, res, next) => {
  const { batch_code, subjects, status = "true" } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      if (!batch_code || !status || !Object.keys(subjects).length) {
        return next(
          errorProvider(
            400,
            "All fields (batch_code, status, subjects) are required"
          )
        );
      }

      await conn.beginTransaction();

      // Check if batch already exists
      const [batchExists] = await conn.query(
        "SELECT COUNT(*) AS count FROM batch WHERE batch_code = ?",
        [batch_code]
      );

      if (batchExists[0].count > 0) {
        conn.release();
        return next(errorProvider(409, "Batch already exists"));
      }

      // Insert batch and retrieve batch_id
      const [batchResult] = await conn.query(
        "CALL InsertBatch(?, ?, ?, @batch_id); SELECT @batch_id AS batch_id;",
        [batch_code, Object.keys(subjects).join(","), status]
      );
      const batch_id = batchResult[1][0].batch_id;

      // Insert batch curriculum lecturer details
      await conn.query("CALL InsertBatchCurriculumLecturer(?, ?);", [
        batch_id,
        JSON.stringify(
          Object.entries(subjects).map(([sub_id, m_id]) => ({ sub_id, m_id }))
        ),
      ]);

      // Create batch subject tables
      await conn.query("CALL CreateBatchSubjectTables(?, ?);", [
        batch_id,
        JSON.stringify(
          Object.entries(subjects).map(([sub_id]) => ({ sub_id }))
        ),
      ]);

      // Create batch students table
      await conn.query("CALL CreateBatchStudentsTable(?, ?);", [
        batch_id,
        JSON.stringify(
          Object.entries(subjects).map(([sub_id]) => ({ sub_id }))
        ),
      ]);

      await conn.commit();
      return res.status(201).json({
        message: "Batch and batch subject details created successfully",
      });
    } catch (error) {
      await conn.rollback();
      console.error("Error creating batch and details:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while creating the batch and details"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateBatch = async (req, res, next) => {
  const { old_subjects, batch_code, subjects, batch_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      if (!batch_id || !batch_code || !Object.keys(subjects).length) {
        return next(
          errorProvider(
            400,
            "All fields (batch_id, status, batch_code, subjects) are required"
          )
        );
      }

      await conn.beginTransaction();

      // Check if batch exists
      const [batchExists] = await conn.query(
        "SELECT COUNT(*) AS count FROM batch WHERE batch_id = ?",
        [batch_id]
      );

      if (batchExists[0].count === 0) {
        conn.release();
        return next(errorProvider(409, "Batch not found"));
      }

      // Update batch details
      await conn.query("CALL UpdateBatchDetails(?, ?, ?);", [
        batch_id,
        batch_code,
        Object.keys(subjects).join(","),
      ]);

      // Drop old tables and columns if subjects changed
      if (!lodash.isEqual(Object.keys(old_subjects), Object.keys(subjects))) {
        await conn.query("CALL DropOldBatchTablesAndColumns(?, ?);", [
          batch_id,
          JSON.stringify(
            Object.entries(old_subjects).map(([sub_id]) => ({ sub_id }))
          ),
        ]);

        await conn.query("CALL CreateNewBatchSubjectTables(?, ?);", [
          batch_id,
          JSON.stringify(
            Object.entries(subjects).map(([sub_id]) => ({ sub_id }))
          ),
        ]);

        await conn.query("CALL AddNewBatchStudentColumns(?, ?);", [
          batch_id,
          JSON.stringify(
            Object.entries(subjects).map(([sub_id]) => ({ sub_id }))
          ),
        ]);
      }

      // Delete old batch curriculum lecturer rows
      await conn.query("CALL DeleteBatchCurriculumLecturerRows(?);", [
        batch_id,
      ]);

      // Re-insert batch curriculum lecturer details
      await conn.query("CALL InsertBatchCurriculumLecturer(?, ?);", [
        batch_id,
        JSON.stringify(
          Object.entries(subjects).map(([sub_id, m_id]) => ({ sub_id, m_id }))
        ),
      ]);

      await conn.commit();
      return res.status(200).json({
        message: "Batch and batch subject details updated successfully",
      });
    } catch (error) {
      await conn.rollback();
      console.error("Error updating batch and details:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while updating the batch and details"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateBatchStatus = async (req, res, next) => {
  const { status, id: batch_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      if (!batch_id || !status) {
        return next(errorProvider(400, "batch_id, status are required"));
      }

      await conn.beginTransaction();

      // Check if batch exists
      const [batchExists] = await conn.query(
        "SELECT COUNT(*) AS count FROM batch WHERE batch_id = ?",
        [batch_id]
      );

      if (batchExists[0].count === 0) {
        conn.release();
        return next(errorProvider(409, "Batch not found"));
      }

      // Update batch details
      await conn.query("CALL updateBatchStatus(?, ?);", [batch_id, status]);

      await conn.commit();
      return res.status(200).json({
        message: "Batch status updated successfully",
      });
    } catch (error) {
      await conn.rollback();
      console.error("Error updating batch and details:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while updating the batch and details"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getStudentsByBatchId = async (req, res, next) => {
  const { batch_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      const query = `SELECT s_id FROM batch_${batch_id}_students`;

      if (batch_id) {
        const [StudentsInTheBatch] = await conn.execute(query);

        if (!StudentsInTheBatch.length) {
          return res.status(200).json([]);
        }

        let StudentsInTheBatchArr = StudentsInTheBatch.map((obj) => {
          let { s_id } = obj;
          return s_id;
        });

        return res.status(200).json(StudentsInTheBatchArr);
      }
    } catch (error) {
      console.error("Error retrieving students:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while retrieving students in the batch"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const addStudentsToTheBatchTable = async (req, res, next) => {
  let { batch_id, oldData, selectedStudents } = req.body;

  if (!oldData || !oldData.length) {
    oldData = [];
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.beginTransaction();

      // Calculate new selections and removed selections
      const newSelections = selectedStudents.filter(
        (s_id) => !oldData.includes(s_id)
      );
      const removedSelections = oldData.filter(
        (s_id) => !selectedStudents.includes(s_id)
      );

      // Remove students from the batch
      if (removedSelections.length) {
        await conn.query("CALL RemoveStudentsFromBatch(?, ?);", [
          batch_id,
          removedSelections.join(","),
        ]);
      }

      // Add students to the batch
      if (newSelections.length) {
        await conn.query("CALL AddStudentsToBatch(?, ?);", [
          batch_id,
          newSelections.join(","),
        ]);
      }

      await conn.commit();
      return res.status(200).json({
        message: "Students of the batch updated successfully",
      });
    } catch (error) {
      await conn.rollback();
      console.error("Error updating students of the batch:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while updating students of the batch"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfBatches = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL GetBatchCount();");

      const { batch_count } = result[0][0];

      return res.status(200).json({
        count: batch_count,
      });
    } catch (error) {
      console.error("Error retrieving number of batches:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving the batch count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getBatchByFacultyId = async (req, res, next) => {
  const { f_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL GetBatchesByFacultyId(?);", [
        f_id,
      ]);

      return res.status(200).json(result[0]); // First result set contains the desired data
    } catch (error) {
      console.error("Error retrieving batches by faculty id:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while retrieving batches by faculty id"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getBathchesByStudent = async (req, res, next) => {
  const { user_id } = req.user;

  try {
    const conn = await pool.getConnection();
    try {
      // Step 1: Get batch IDs and student ID
      const [studentDetails] = await conn.query("CALL GetStudentBatchIds(?);", [
        user_id,
      ]);

      if (!studentDetails[0].length || !studentDetails[0][0].batch_ids) {
        return res.status(404).json({ message: "No batches found" });
      }

      const batchIds = studentDetails[0][0].batch_ids;
      const s_id = studentDetails[0][0].s_id;

      // Step 2: Fetch batch details dynamically
      const [results] = await conn.query("CALL GetStudentBatchDetails(?, ?);", [
        batchIds,
        s_id,
      ]);

      return res.status(200).json(results[0]); // First result set contains the data
    } catch (error) {
      console.error("Error retrieving student:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving student batches")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const setBatchTimePeriod = async (req, res, next) => {
  const { batch_id, students_end, lecturers_end } = req.body;

  if (!batch_id || !students_end || !lecturers_end) {
    return next(errorProvider(400, "Missing required fields."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "5", students_end, students_end]
      );

      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "4", lecturers_end, lecturers_end]
      );

      return res
        .status(200)
        .json({ message: "Time period set successfully for the batch." });
    } catch (error) {
      console.error("Error setting time period for batch:", error);
      return next(
        errorProvider(500, "Failed to set time period for the batch.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const getBatchTimePeriod = async (req, res, next) => {
  const { batch_id } = req.body;

  if (!batch_id) {
    return next(errorProvider(400, "Missing required fields."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.execute(
        `SELECT user_type, end_date FROM batch_time_periods WHERE batch_id = ?`,
        [batch_id]
      );

      console.log(results);

      return res.status(200).json(results);
    } catch (error) {
      console.error("Error getting time period for batch:", error);
      return next(
        errorProvider(500, "Failed to get time period for the batch.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const checkAccessWithinBatchTimePeriod = async (
  user_id,
  batch_id,
  user_type
) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.execute(
        `SELECT start_date, end_date FROM batch_time_periods 
         WHERE batch_id = ? AND user_type = ?`,
        [batch_id, user_type]
      );

      if (!results.length) {
        throw new Error("No access period defined for this operation.");
      }

      const { start_date, end_date } = results[0];
      const currentTime = new Date();

      if (
        currentTime < new Date(start_date) ||
        currentTime > new Date(end_date)
      ) {
        throw new Error(
          "Access denied: Not within the allowed time period for this batch."
        );
      }

      return true;
    } catch (error) {
      console.error("Error checking batch access:", error);
      throw error;
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    throw error;
  }
};

export const getNonBatchStudents = async (req, res, next) => {
  const { batch_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query(
        "CALL GetNonBatchStudentsByFaculty(?);",
        [batch_id]
      );

      return res.status(200).json(results[3]);
    } catch (error) {
      console.error("Error fetching non-batch students by faculty:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while fetching non-batch students by faculty."
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const getBatchFullDetails = async (req, res, next) => {
  const { batch_id } = req.body;

  if (!batch_id) {
    return next(errorProvider(400, "Batch ID is required."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query("CALL GetBatchFullDetails(?);", [
        batch_id,
      ]);

      if (!results[0]?.length) {
        return res
          .status(404)
          .json({ message: "No details found for the provided batch ID." });
      }

      return res.status(200).json(results[0][0]); // Return the first result set
    } catch (error) {
      console.error("Error fetching batch full details:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while fetching batch full details."
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};
