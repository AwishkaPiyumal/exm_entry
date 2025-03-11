import pool from "../config/db.js";
import errorProvider from "../utils/errorProvider.js";

export const getAllStudents = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [students] = await conn.query("CALL GetAllStudents();");

      if (!students[0].length) {
        return res.status(404).json({ message: "No students found" });
      }

      return res.status(200).json(students[0]);
    } catch (error) {
      console.error("Error retrieving students:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving students")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllManagers = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [managers] = await conn.query("CALL GetAllManagers();");

      if (!managers[0].length) {
        return res.status(404).json({ message: "No managers found" });
      }

      return res.status(200).json(managers[0]);
    } catch (error) {
      console.error("Error retrieving managers:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving managers")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getAllActiveManagers = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [managers] = await conn.query("CALL GetAllActiveManagers();");

      if (!managers[0].length) {
        return res.status(404).json({ message: "No active managers found" });
      }

      return res.status(200).json(managers[0]);
    } catch (error) {
      console.error("Error retrieving active managers:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving active managers")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getManagerById = async (req, res, next) => {
  const { user_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      const [manager] = await conn.query("CALL GetManagerById(?);", [user_id]);

      if (!manager[0].length) {
        return res.status(404).json({ message: "No manager found" });
      }

      return res.status(200).json(manager[0][0]);
    } catch (error) {
      console.error("Error retrieving manager:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving manager")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getStudentById = async (req, res, next) => {
  const { user_id } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      const [student] = await conn.query("CALL GetStudentById(?);", [user_id]);

      if (!student[0].length) {
        return res.status(404).json({ message: "No student found" });
      }

      return res.status(200).json(student[0][0]);
    } catch (error) {
      console.error("Error retrieving student:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving student")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getStudentByDegShort = async (req, res, next) => {
  const { short } = req.body;

  try {
    const conn = await pool.getConnection();
    try {
      const [students] = await conn.query("CALL GetStudentsByDegreeShort(?);", [
        short,
      ]);

      if (!students[0].length) {
        return res
          .status(404)
          .json({ message: "No students found in current faculty" });
      }

      return res.status(200).json(students[0]);
    } catch (error) {
      console.error("Error retrieving students:", error);
      return next(
        errorProvider(500, "An error occurred while retrieving students")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateStudent = async (req, res, next) => {
  const {
    name,
    f_id,
    email,
    s_id,
    user_name,
    contact_no,
    index_num = "",
  } = req.body;

  if (!s_id || !name || !f_id || !email || !user_name) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [results] = await conn.query(
        "CALL UpdateStudent(?, ?, ?, ?, ?, ?, ?);",
        [name, f_id, s_id, email, user_name, contact_no, index_num]
      );

      let desc = `Student updated for s_id=${s_id}, name=${name}, f_id=${f_id}, email=${email}, user_name=${user_name}, contact_no=${contact_no}, index_num=${index_num}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      return res.status(200).json({ message: "Student updated successfully" });
    } catch (error) {
      if (error.sqlMessage?.includes("Email or username already exists")) {
        return next(errorProvider(409, "Email or username already exists"));
      }
      console.error("Error updating student:", error);
      return next(
        errorProvider(500, "An error occurred while updating the student")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateStudentStatus = async (req, res, next) => {
  const { status, id: s_id } = req.body;

  if (!s_id || !status) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL updateStudentStatus(?, ?);", [status, s_id]);

      let desc = `Student status changed for s_id=${s_id} to status=${status}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      return res
        .status(200)
        .json({ message: "Student status updated successfully" });
    } catch (error) {
      if (error.sqlMessage?.includes("Email or username already exists")) {
        return next(errorProvider(409, "Email or username already exists"));
      }
      console.error("Error updating student:", error);
      return next(
        errorProvider(500, "An error occurred while updating the student")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateManager = async (req, res, next) => {
  const { name, email, contact_no, m_id, user_name } = req.body;

  if (!m_id || !name || !email || !contact_no || !user_name) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL UpdateManager(?, ?, ?, ?, ?);", [
        name,
        email,
        user_name,
        contact_no,
        m_id,
      ]);

      let desc = `Manager updated for m_id=${m_id}, name=${name}, email=${email}, user_name=${user_name}, contact_no=${contact_no}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      return res.status(200).json({ message: "Manager updated successfully" });
    } catch (error) {
      if (error.sqlMessage?.includes("Email or username already exists")) {
        return next(errorProvider(409, "Email or username already exists"));
      }
      console.error("Error updating manager:", error);
      return next(
        errorProvider(500, "An error occurred while updating the manager")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const updateManagerStatus = async (req, res, next) => {
  const { status, id: m_id } = req.body;

  if (!m_id || !status) {
    return next(errorProvider(400, "Missing required fields"));
  }

  try {
    const conn = await pool.getConnection();
    try {
      await conn.query("CALL updateManagerStatus(?, ?);", [status, m_id]);

      let desc = `Manager status changed for m_id=${m_id} to status=${status}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      return res
        .status(200)
        .json({ message: "Manager status updated successfully" });
    } catch (error) {
      console.error("Error updating manager:", error);
      return next(
        errorProvider(500, "An error occurred while updating the manager")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfManagers = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL GetNoOfManagers();");

      const { manager_count } = result[0][0];

      return res.status(200).json({
        count: manager_count,
      });
    } catch (error) {
      console.error("Error retrieving number of managers:", error);
      return next(
        errorProvider(500, "An error occurred while fetching the manager count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getNoOfStudents = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL GetNoOfStudents();");

      const { student_count } = result[0][0];

      return res.status(200).json({
        count: student_count,
      });
    } catch (error) {
      console.error("Error retrieving number of students:", error);
      return next(
        errorProvider(500, "An error occurred while fetching the student count")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const getSummaryData = async (req, res, next) => {
  try {
    const conn = await pool.getConnection();
    try {
      const [result] = await conn.query("CALL GetAdminSummary();");

      return res.status(200).json(result[0][0]);
    } catch (error) {
      console.error("Error retrieving summary data:", error);
      return next(
        errorProvider(500, "An error occurred while fetching the summary data")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};
