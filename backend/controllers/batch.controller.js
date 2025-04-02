import pool from "../config/db.js";
import errorProvider from "../utils/errorProvider.js";
import { parseString } from "../utils/functions.js";
import lodash from "lodash";

import streamifier from "streamifier";
import csv from "csv-parser";
import fs from "fs";
import path from "path";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));

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
        application_open: batch[0][0].application_open,
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
  const {
    batch_code,
    subjects,
    status = "true",
    deg_id,
    application_open,
    academic_year,
    level,
    sem_no,
    students_end,
    lecturers_end,
    hod_end,
    dean_end,
  } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      if (
        !batch_code ||
        !status ||
        !Object.keys(subjects).length ||
        !deg_id ||
        !application_open ||
        !academic_year ||
        !level ||
        !sem_no ||
        !students_end ||
        !lecturers_end ||
        !hod_end ||
        !dean_end
      ) {
        return next(errorProvider(400, "All fields are required"));
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
        "CALL InsertBatch(?, ?, ?, ?, ?, ?, ?, ?, @batch_id); SELECT @batch_id AS batch_id;",
        [
          batch_code,
          Object.keys(subjects).join(","),
          status,
          deg_id,
          application_open,
          academic_year,
          level,
          sem_no,
        ]
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

      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "3", hod_end, hod_end]
      );

      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "2", dean_end, dean_end]
      );

      let desc = `Batch created with batch_id=${batch_id}, application_open=${application_open}, students_end=${students_end}, lecturers_end=${lecturers_end}, hod_end=${hod_end}, dean_end=${dean_end}, sub_ids=${Object.keys(
        subjects
      ).join(",")}, m_ids=${Object.values(subjects).join(",")}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();
      return res.status(201).json({
        message: "Batch created successfully",
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
  const {
    old_subjects,
    batch_code,
    subjects,
    batch_id,
    deg_id,
    application_open,
    academic_year,
    level,
    sem_no,
    students_end,
    lecturers_end,
    hod_end,
    dean_end,
  } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      if (
        !batch_id ||
        !batch_code ||
        !Object.keys(subjects).length ||
        !deg_id ||
        !application_open ||
        !academic_year ||
        !level ||
        !sem_no ||
        !students_end ||
        !lecturers_end ||
        !hod_end ||
        !dean_end
      ) {
        return next(errorProvider(400, "All fields are required"));
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
      await conn.query("CALL UpdateBatchDetails(?, ?, ?, ?, ?, ?, ?, ?);", [
        batch_id,
        batch_code,
        Object.keys(subjects).join(","),
        deg_id,
        application_open,
        academic_year,
        level,
        sem_no,
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

      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "3", hod_end, hod_end]
      );

      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "2", dean_end, dean_end]
      );

      let desc = `Batch updated with batch_id=${batch_id}, application_open=${application_open}, students_end=${students_end}, lecturers_end=${lecturers_end}, hod_end=${hod_end}, dean_end=${dean_end}, sub_ids=${Object.keys(
        subjects
      ).join(",")}, m_ids=${Object.values(subjects).join(",")}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      await conn.commit();
      return res.status(200).json({
        message: "Batch updated successfully",
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

      let desc = `Batch status changed for batch_id=${batch_id} to status=${status}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

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
      const tableName = `batch_${batch_id}_students`;

      if (batch_id) {
        const [StudentsInTheBatch] = await conn.query(`SELECT s_id FROM ??`, [
          tableName,
        ]);

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

      let desc = `Batch students updated for batch_id=${batch_id}, droped=${removedSelections.join(
        ","
      )}, inserted=${newSelections.join(",")}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

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

export const getBatchesByStudent = async (req, res, next) => {
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
  const { batch_id, students_end, lecturers_end, hod_end, dean_end } = req.body;

  if (!batch_id || !students_end || !lecturers_end || !hod_end || !dean_end) {
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

      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "3", hod_end, hod_end]
      );

      await conn.execute(
        `INSERT INTO batch_time_periods (batch_id, user_type, end_date)
         VALUES (?, ?, ?)
         ON DUPLICATE KEY UPDATE end_date = ?`,
        [batch_id, "2", dean_end, dean_end]
      );

      let desc = `Batch time period inserted or updated for batch_id=${batch_id} to students_end=${students_end}, lecturers_end=${lecturers_end}, hod_end=${hod_end}, dean_end=${dean_end}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

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

export const uploadAttendanceSheet = async (req, res, next) => {
  const results = [];
  const failedCases = [];
  const unmatchedSubjects = [];
  const unmatchedStudents = [];

  try {
    if (!req.file || !req.file.buffer || !req.body.batch_id) {
      return next(errorProvider(400, "No file uploaded or batch ID provided."));
    }

    const batchId = req.body.batch_id;
    const buffer = req.file.buffer;
    const stream = streamifier.createReadStream(buffer);

    let isFirstRow = true;
    let incomingSubjects = [];
    stream
      .pipe(csv({ headers: true })) // Read with headers
      .on("data", (row) => {
        if (isFirstRow) {
          incomingSubjects = Object.values(row)
            .slice(1)
            .map((header) => header.replace(/[^a-zA-Z0-9]/g, ""));
          isFirstRow = false;
        } else {
          results.push(row); // Collect rows
        }
      })
      .on("end", async () => {
        const conn = await pool.getConnection();
        try {
          await conn.beginTransaction();

          // Fetch subject IDs from DB for the batch
          const [dbSubjectRows] = await conn.query(
            "SELECT bcl.sub_id, c.sub_code FROM batch_curriculum_lecturer bcl join curriculum c ON bcl.sub_id=c.sub_id WHERE bcl.batch_id = ?",
            [batchId]
          );

          const dbSubjects = dbSubjectRows.reduce((acc, row) => {
            const sanitizedCode = row.sub_code.replace(/[^a-zA-Z0-9]/g, "");
            acc[sanitizedCode] = row.sub_id;
            return acc;
          }, {});

          // Map incoming subjects to database sub_ids
          const subIdOrder = incomingSubjects.map((incomingCode) => {
            const matchingKey = Object.keys(dbSubjects).find(
              (key) => key === incomingCode
            );

            if (!matchingKey) {
              unmatchedSubjects.push(incomingCode);
              return null;
            }

            return dbSubjects[matchingKey];
          });

          if (unmatchedSubjects.length > 0) {
            failedCases.push(
              `Unmatched subjects: ${unmatchedSubjects.join(", ")}`
            );
          }

          // Process each row and update attendance
          for (const row of results) {
            // Dynamically access "user_name" (first column) and the remaining columns (attendance data)
            const user_name = row._0; // First column is user_name
            const attendanceData = Object.entries(row)
              .filter(([key, _]) => key !== "_0") // Exclude the first column
              .map(([_, value]) => value); // Collect only the values for attendance

            // Fetch student ID based on user_name
            const [userResult] = await conn.query(
              "SELECT s.s_id FROM user u JOIN student s ON u.user_id = s.user_id WHERE u.user_name = ?",
              [user_name]
            );

            if (userResult.length === 0) {
              unmatchedStudents.push({ user_name, attendance: attendanceData });
              continue;
            }

            const s_id = userResult[0].s_id;

            // Build dynamic update query using attendanceData and subIdOrder
            const updates = subIdOrder
              .map((sub_id, index) => {
                const columnValue = attendanceData[index] || 0; // Match value to the sub_id order
                return sub_id
                  ? `sub_${sub_id} = ${conn.escape(columnValue)}`
                  : null;
              })
              .filter(Boolean)
              .join(", ");

            if (updates) {
              const tableName = `batch_${batchId}_students`;
              await conn.query(
                `UPDATE ${tableName} SET ${updates} WHERE s_id = ?`,
                [s_id]
              );
            }
          }

          let desc = `Batch attendace sheet uploaded for batch_id=${batchId}`;
          await conn.query("CALL LogAdminAction(?);", [desc]);

          await conn.commit();

          // Generate a failed cases file if needed
          if (failedCases.length > 0 || unmatchedStudents.length > 0) {
            const failedFilePath = path.join(
              __dirname,
              "failed_cases_attendance.txt"
            );
            const failedContent = [
              ...failedCases,
              ...unmatchedStudents.map(
                (student) =>
                  `Unmatched student: ${
                    student.user_name
                  }, Attendance: ${JSON.stringify(student.attendance)}`
              ),
            ].join("\n");

            fs.writeFileSync(failedFilePath, failedContent);

            res.setHeader(
              "Content-Disposition",
              `attachment; filename=failed_cases_attendance.txt`
            );
            res.setHeader("Content-Type", "text/plain");

            // Stream the file to the response
            const fileStream = fs.createReadStream(failedFilePath);
            fileStream.pipe(res);

            fileStream.on("end", () => {
              fs.unlinkSync(failedFilePath);
            });

            return;
          }

          res.status(201).json({
            message: "Attendance sheet processed successfully.",
          });
        } catch (error) {
          await conn.rollback();
          console.error("Error during transaction:", error);
          return next(
            errorProvider(500, "Failed to process attendance sheet.")
          );
        } finally {
          conn.release();
        }
      })
      .on("error", (err) => {
        console.error("Error processing CSV:", err);
        return next(errorProvider(500, "Error processing CSV file."));
      });
  } catch (error) {
    console.error("Error handling upload:", error);
    return next(errorProvider(500, "Failed to handle uploaded file."));
  }
};

export const getAllBatchesForDepartment = async (req, res, next) => {
  const { user_id, role_id } = req.user;

  if (!user_id) {
    return next(errorProvider(400, "User ID is required."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [departments] = await conn.query(
        "SELECT d_id FROM department WHERE user_id = ? AND status = 'true'",
        [user_id]
      );

      if (departments.length === 0) {
        return res.status(404).json({ message: "No active departments found" });
      }
      let department = departments[0];
      const result = [];

      // Step 2: Get active degrees under this faculty
      const [degrees] = await conn.query(
        "CALL GetActiveDegreesInDepartment(?)",
        [department.d_id]
      );

      if (degrees[0].length > 0) {
        for (const degree of degrees[0]) {
          // Step 2: Get active degrees under this faculty
          const [batches] = await conn.query(
            "CALL GetActiveBatchesWithinDeadline(?, ?)",
            [degree.deg_id, role_id]
          );

          if (batches[0].length > 0) {
            batches[0].forEach((batch) =>
              result.push({ ...batch, deg_name: degree.deg_name })
            );
          }
        }
      }

      return res.status(200).json(result);
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllBatchesForFaculty = async (req, res, next) => {
  const { user_id, role_id } = req.user;

  if (!user_id) {
    return next(errorProvider(400, "User ID is required."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      // Step 1: Get faculty ID for the dean
      const [faculty] = await conn.query(
        "SELECT f_id FROM faculty WHERE user_id = ? AND status = 'true'",
        [user_id]
      );

      if (faculty.length === 0) {
        return res.status(404).json({ message: "Faculty not found" });
      }
      const facultyId = faculty[0].f_id;

      // Step 2: Get active departments under this faculty
      const [departments] = await conn.query(
        "CALL GetDepartmentsByFacultyId(?)",
        [facultyId]
      );

      if (departments[0].length === 0) {
        return res.status(404).json({ message: "No active departments found" });
      }

      const result = [];

      for (const department of departments[0]) {
        // Step 2: Get active degrees under this faculty
        const [degrees] = await conn.query(
          "CALL GetActiveDegreesInDepartment(?)",
          [department.d_id]
        );

        if (degrees[0].length > 0) {
          for (const degree of degrees[0]) {
            // Step 2: Get active degrees under this faculty
            const [batches] = await conn.query(
              "CALL GetActiveBatchesWithinDeadline(?, ?)",
              [degree.deg_id, role_id]
            );

            if (batches[0].length > 0) {
              batches[0].forEach((batch) =>
                result.push({ ...batch, deg_name: degree.deg_name })
              );
            }
          }
        }
      }

      res.status(200).json(result);
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getDeadlinesForBatch = async (req, res, next) => {
  const { batch_id } = req.body;

  if (!batch_id) {
    return next(errorProvider(400, "batch_id is required."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [deadlines] = await conn.query("CALL GetDeadlinesForBatch(?)", [
        batch_id,
      ]);

      if (deadlines[0].length === 0) {
        return res.status(404).json({ message: "No deadlines available" });
      }

      res.status(200).json(deadlines[0]);
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllActiveBatchesProgesses = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      // Step 1: Get faculty ID for the dean
      const [faculty] = await conn.query(
        "CALL GetAllActiveBatchesProgesses()",
        []
      );

      res.status(200).json(faculty[0]);
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getBatchOpenDate = async (req, res, next) => {
  const { batch_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      // Call the first stored procedure to get batch details
      const [batch] = await conn.query("CALL GetBatchOpenDate(?)", [batch_id]);

      if (!batch[0].length) {
        return next(errorProvider(404, "No Batches found"));
      }

      // Parse batch_code in Node.js
      const application_open = batch[0][0].application_open;

      return res.status(200).json({ application_open });
    } catch (error) {
      console.error("Error retrieving batch application_open date:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while retrieving batch application_open date"
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
