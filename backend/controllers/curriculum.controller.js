import pool from "../config/db.js";
import errorProvider from "../utils/errorProvider.js";

export const getAllCurriculums = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetAllCurriculums();");

      return res.status(200).json(results[0]); // First result set contains the data
    } catch (error) {
      console.error("Error fetching curriculum details:", error);
      return next(errorProvider(500, "Failed to fetch curriculum details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getCurriculumById = async (req, res, next) => {
  const { sub_id } = req.body;

  if (!sub_id) {
    return next(errorProvider(400, "Missing sub_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetCurriculumById(?);", [
        sub_id,
      ]);

      if (results[0].length === 0) {
        return res.status(404).json({
          message: "No curriculum details found for the given sub_id.",
        });
      }

      return res.status(200).json(results[0][0]); // First result set, first record
    } catch (error) {
      console.error("Error fetching curriculum details:", error);
      return next(errorProvider(500, "Failed to fetch curriculum details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllCurriculumsWithExtraDetails = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetAllCurriculumsWithExtraDetails();"
      );

      return res.status(200).json(results[0]); // First result set contains the data
    } catch (error) {
      console.error("Error fetching curriculum details:", error);
      return next(errorProvider(500, "Failed to fetch curriculum details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getCurriculumByDegLevSem = async (req, res, next) => {
  const { deg_id, level, sem_no } = req.body;

  if (!deg_id || !level || !sem_no) {
    return next(errorProvider(400, "Missing required fields."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query(
        "CALL GetCurriculumByDegLevSem(?, ?, ?);",
        [deg_id, level, sem_no]
      );

      return res.status(200).json(results[0]); // First result set contains the data
    } catch (error) {
      console.error("Error fetching curriculum details:", error);
      return next(errorProvider(500, "Failed to fetch curriculum details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getCurriculumsByLecId = async (req, res, next) => {
  const { m_id } = req.user;

  if (!m_id) {
    return next(errorProvider(400, "Missing m_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetCurriculumsByLecId(?);", [
        m_id,
      ]);

      if (results[0].length === 0) {
        return res
          .status(404)
          .json({ message: "No curriculum details found for the given m_id." });
      }

      return res.status(200).json({ curriculum: results[0] }); // First result set contains the data
    } catch (error) {
      console.error("Error fetching curriculum details:", error);
      return next(errorProvider(500, "Failed to fetch curriculum details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getCurriculumsByDid = async (req, res, next) => {
  const { m_id } = req.user;

  if (!m_id) {
    return next(errorProvider(400, "Missing hod_id."));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [results] = await conn.query("CALL GetCurriculumsByDid(?);", [
        m_id,
      ]);

      if (results[0].length === 0) {
        return res.status(404).json({
          message: "No curriculum details found for the given hod_id.",
        });
      }

      return res.status(200).json({ curriculum: results[0] }); // First result set contains the data
    } catch (error) {
      console.error("Error fetching curriculum details by hod_id:", error);
      return next(
        errorProvider(
          500,
          "Failed to fetch curriculum details for the given hod_id"
        )
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error establishing database connection:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const createCurriculum = async (req, res, next) => {
  const {
    sub_code,
    sub_name,
    sem_no,
    deg_id,
    level,
    status = "true",
  } = req.body;

  if (!sub_code || !sub_name || !sem_no || !deg_id || !level || !status) {
    return res.status(400).json({ message: "All fields are required" });
  }

  try {
    const conn = await pool.getConnection();

    try {
      await conn.query("CALL CreateCurriculum(?, ?, ?, ?, ?, ?);", [
        sub_code,
        sub_name,
        sem_no,
        deg_id,
        level,
        status,
      ]);

      return res.status(201).json({
        message: "Curriculum record created successfully",
      });
    } catch (error) {
      console.error("Error creating curriculum:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while creating the curriculum record"
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

export const updateCurriculum = async (req, res, next) => {
  const { sub_code, sub_name, sem_no, deg_id, level, sub_id } = req.body;

  if (!sub_id) {
    return next(errorProvider(400, "Subject ID (sub_id) is required"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [result] = await conn.query(
        "CALL UpdateCurriculum(?, ?, ?, ?, ?, ?);",
        [sub_id, sub_code, sub_name, sem_no, deg_id, level]
      );

      if (result.affectedRows === 0) {
        return next(
          errorProvider(404, "Curriculum record not found or no changes made")
        );
      }

      return res
        .status(200)
        .json({ message: "Curriculum updated successfully" });
    } catch (error) {
      console.error("Error updating curriculum:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while updating the curriculum record"
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

export const updateCurriculumStatus = async (req, res, next) => {
  const { status, id: sub_id } = req.body;

  if (!sub_id || !status) {
    return next(errorProvider(400, "Subject ID (sub_id) is required"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [result] = await conn.query("CALL updateCurriculumStatus(?, ?);", [
        sub_id,
        status,
      ]);

      if (result.affectedRows === 0) {
        return next(
          errorProvider(404, "Curriculum record not found or no changes made")
        );
      }

      return res
        .status(200)
        .json({ message: "Curriculum status updated successfully" });
    } catch (error) {
      console.error("Error updating curriculum:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while updating the curriculum record"
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

export const getNoOfCurriculums = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL GetNoOfCurriculums();");
      return res.status(200).json({ count: result[0][0].curriculum_count });
    } catch (error) {
      console.error("Error retrieving number of curriculums:", error);
      return next(
        errorProvider(500, "An error occurred while fetching curriculum count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getCurriculumBybatchId = async (req, res, next) => {
  const { batch_id } = req.body;

  if (!batch_id) {
    return next(errorProvider(400, "Batch ID is required."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query("CALL GetCurriculumByBatchId(?);", [
        batch_id,
      ]);
      console.log(results[0]);
      return res.status(200).json(results[0]);
    } catch (error) {
      console.error("Error fetching curriculum details:", error);
      return next(errorProvider(500, "Failed to fetch curriculum details"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getStudentApplicationDetails = async (req, res, next) => {
  const { user_id } = req.user;

  if (!user_id) {
    return next(errorProvider(400, "User ID is required."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query(
        "CALL GetStudentApplicationDetails(?);",
        [user_id]
      );

      const studentDetails = results[0][0]; // First result set
      const subjects = results[1]; // Second result set

      if (!subjects.length) {
        return next(errorProvider(404, "No subjects found for this batch."));
      }

      const batchId = subjects[0].batch_id; // Ensure batch ID is retrieved

      if (!batchId) {
        return next(errorProvider(500, "Batch ID is missing."));
      }

      // Dynamic attendance query
      const attendanceQuery = `
        SELECT ${subjects.map((s) => `sub_${s.sub_id}`).join(", ")}
        FROM batch_${batchId}_students
        WHERE s_id = ?
      `;

      const [attendanceResult] = await conn.execute(attendanceQuery, [
        studentDetails.s_id,
      ]);

      if (!attendanceResult.length) {
        return next(
          errorProvider(
            404,
            "No attendance found for this student in the batch"
          )
        );
      }

      // Format the response
      const attendance = attendanceResult[0];
      const response = {
        ...studentDetails,
        subjects: subjects.map((subject) => ({
          sub_code: subject.sub_code,
          sub_name: subject.sub_name,
          attendance: attendance[`sub_${subject.sub_id}`] || "N/A",
        })),
      };

      res.status(200).json(response);
    } catch (error) {
      console.error("Error fetching student application details:", error);
      return next(
        errorProvider(
          500,
          "An error occurred while fetching student application details"
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

export const getAllSubjectsForManager = async (req, res, next) => {
  const { user_id } = req.user;

  if (!user_id) {
    return next(errorProvider(400, "User ID is required."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      // Call the stored procedure
      const [subjects] = await conn.query("CALL GetAllSubjectsForManager(?);", [
        user_id,
      ]);

      if (!subjects.length) {
        return res.status(404).json({
          message: "No subjects found for the given user ID.",
        });
      }

      return res.status(200).json(subjects[0]);
    } catch (error) {
      console.error("Error fetching subjects for manager:", error);

      if (error.code === "45000") {
        return next(errorProvider(400, error.sqlMessage));
      }

      return next(
        errorProvider(
          500,
          "An error occurred while fetching subjects for the manager."
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

export const getAppliedStudentsForSubject = async (req, res, next) => {
  const { user_id, role_id } = req.user;
  const { batch_id, sub_id } = req.body;

  if (!user_id || !batch_id || !sub_id || !role_id) {
    return next(errorProvider(400, "Missing required fields."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query(
        "CALL GetAppliedStudentsByBatchAndSubject(?, ?, ?, ?);",
        [user_id, batch_id, sub_id, role_id]
      );

      return res.status(200).json(results[0]);
    } catch (error) {
      console.error("Error fetching applied students for subject:", error);

      if (error.code === "45000") {
        return next(errorProvider(403, error.sqlMessage));
      }

      return next(
        errorProvider(500, "An error occurred while fetching applied students.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};

export const updateEligibility = async (req, res, next) => {
  const { user_id, role_id } = req.user;
  const { batch_id, sub_id, eligibility, s_id } = req.body;

  console.log(user_id, role_id, batch_id, sub_id, eligibility, s_id);
  if (!user_id || !s_id || !sub_id || !batch_id || !eligibility || !role_id) {
    return next(errorProvider(400, "Missing required fields."));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL UpdateEligibility(?, ?, ?, ?, ?, ?);", [
        user_id,
        s_id,
        sub_id,
        batch_id,
        eligibility,
        role_id,
      ]);

      return res
        .status(200)
        .json({ message: "Eligibility updated successfully." });
    } catch (error) {
      console.error("Error updating eligibility:", error);

      if (error.code === "45000") {
        return next(errorProvider(403, error.sqlMessage));
      }

      return next(
        errorProvider(500, "An error occurred while updating eligibility.")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection."));
  }
};
