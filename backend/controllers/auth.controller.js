import csv from "csv-parser";
import streamifier from "streamifier";
import pool from "../config/db.js";
import { generatePassword, hashPassword } from "../utils/functions.js";
import jwt from "jsonwebtoken";
import { verifyPassword } from "../utils/functions.js";
import errorProvider from "../utils/errorProvider.js";
import mailer from "../utils/mailer.js";
const JWT_SECRET = process.env.JWT_SECRET || "abc123";

export const studentRegister = async (req, res, next) => {
  const {
    user_name,
    name,
    f_id,
    email,
    contact_no,
    index_num = "",
    status = "true",
  } = req.body;
  const role_id = 5;

  if (!user_name || !name || !f_id || !email || !status || !contact_no) {
    return next(errorProvider(400, "Missing credentials"));
  }

  try {
    const password = await generatePassword();
    console.log("Generated password:", password);

    const hashedPassword = await hashPassword(password);

    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Check if user exists
      const [userExistsResult] = await conn.query(
        "CALL CheckUserExists(?, ?, @userExists); SELECT @userExists AS userExists;",
        [user_name, email]
      );

      const userExists = userExistsResult[1][0].userExists;

      if (userExists) {
        conn.release();
        return next(errorProvider(409, "User already exists"));
      }

      const [userResult] = await conn.query(
        "CALL InsertUser(?, ?, ?, ?, @userId); SELECT @userId AS userId;",
        [user_name, email, hashedPassword, role_id]
      );
      const user_id = userResult[1][0].userId;

      const [studentResult] = await conn.query(
        "CALL InsertStudent(?, @studentId); SELECT @studentId AS studentId;",
        [user_id]
      );
      const s_id = studentResult[1][0].studentId;

      // Insert student details
      await conn.query("CALL InsertStudentDetail(?, ?, ?, ?,? ,?);", [
        s_id,
        name,
        f_id,
        status,
        index_num,
        contact_no,
      ]);

      await conn.commit();
      await mailer(email, user_name, password);

      return res
        .status(201)
        .json({ message: "Student registered successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error during transaction:", error);
      return next(errorProvider(500, "Failed to register student"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during registration:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const MultipleStudentsRegister = async (req, res, next) => {
  const results = [];
  const failedRecords = [];
  console.log(req.file);

  try {
    // Check if file exists
    if (!req.file || !req.file.buffer) {
      return next(errorProvider(400, "No file uploaded"));
    }

    const buffer = req.file.buffer; // Access the file buffer
    const stream = streamifier.createReadStream(buffer); // Convert buffer to readable stream

    // Parse CSV data
    stream
      .pipe(csv({ headers: true, skipLines: 1 })) // Read the file
      .on("data", (row) => {
        results.push(row); // Collect all rows
      })
      .on("end", async () => {
        console.log(results[0]._0.split(";"));
        const conn = await pool.getConnection();

        try {
          await conn.beginTransaction();

          for (const record of results) {
            const { name, user_name, f_id, email, status, contact_no } =
              record._0.split(";");

            // Validate fields
            if (
              !user_name ||
              !name ||
              !f_id ||
              !email ||
              !status ||
              !contact_no
            ) {
              failedRecords.push({ record, error: "Missing credentials" });
              continue;
            }

            const password = await generatePassword();
            const hashedPassword = await hashPassword(password);

            // Check if user exists
            const [userExistsResult] = await conn.query(
              "CALL CheckUserExists(?, ?, @userExists); SELECT @userExists AS userExists;",
              [user_name, email]
            );

            const userExists = userExistsResult[1][0].userExists;

            if (userExists) {
              failedRecords.push({ record, error: "User already exists" });
              continue;
            }

            // Insert user
            const [userResult] = await conn.query(
              "CALL InsertUser(?, ?, ?, ?, @userId); SELECT @userId AS userId;",
              [user_name, email, hashedPassword, 5]
            );
            const user_id = userResult[1][0].userId;

            // Insert student
            const [studentResult] = await conn.query(
              "CALL InsertStudent(?, @studentId); SELECT @studentId AS studentId;",
              [user_id]
            );
            const s_id = studentResult[1][0].studentId;

            // Insert student details
            await conn.query("CALL InsertStudentDetail(?, ?, ?, ?,? ,?);", [
              s_id,
              name,
              f_id,
              status,
              index_num,
              contact_no,
            ]);

            // Send email
            await mailer(email, user_name, password);
          }
          // console.log(failedRecords);

          await conn.commit();
          return res.status(201).json({
            message: "Students registered successfully",
            failedRecords,
          });
        } catch (error) {
          await conn.rollback();
          console.error("Error during transaction:", error);
          return next(errorProvider(500, "Failed to register students"));
        } finally {
          conn.release();
        }
      })
      .on("error", (err) => {
        console.error("Error processing CSV:", err);
        return next(errorProvider(500, "Error processing CSV file"));
      });
  } catch (error) {
    console.error("Error handling upload:", error);
    return next(errorProvider(500, "Failed to handle uploaded file"));
  }
};

export const managerRegister = async (req, res, next) => {
  const { user_name, name, email, contact_no, status = "true" } = req.body;
  const role_id = 4;

  if (!user_name || !name || !email || !contact_no || !status) {
    return next(errorProvider(400, "Missing credentials"));
  }

  try {
    const password = await generatePassword();
    console.log("Generated password:", password);
    const hashedPassword = await hashPassword(password);

    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      // Check if user exists
      const [userExistsResult] = await conn.query(
        "CALL CheckUserExists(?, ?, @userExists); SELECT @userExists AS userExists;",
        [user_name, email]
      );
      const userExists = userExistsResult[1][0].userExists;

      if (userExists) {
        conn.release();
        return next(errorProvider(409, "User already exists"));
      }

      // Insert user
      const [userResult] = await conn.query(
        "CALL InsertUser(?, ?, ?, ?, @userId); SELECT @userId AS userId;",
        [user_name, email, hashedPassword, role_id]
      );
      const user_id = userResult[1][0].userId;

      // Insert manager
      const [managerResult] = await conn.query(
        "CALL InsertManager(?, @managerId); SELECT @managerId AS managerId;",
        [user_id]
      );
      const m_id = managerResult[1][0].managerId;

      // Insert manager details
      await conn.query("CALL InsertManagerDetail(?, ?, ?, ?);", [
        m_id,
        name,
        contact_no,
        status,
      ]);

      await conn.commit();
      await mailer(email, user_name, password);

      res.status(201).json({ message: "Manager registered successfully" });
    } catch (error) {
      await conn.rollback();
      console.error("Error during transaction:", error);
      return next(
        errorProvider(500, "An error occurred while registering manager")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during registration:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const login = async (req, res, next) => {
  const { user_name_or_email, password, remember_me } = req.body;

  if (!user_name_or_email || !password) {
    return next(errorProvider(400, "Missing credentials"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      let user_id, hashedPassword, role_id;

      // Call the stored procedure
      const [result] = await conn.query(
        "CALL GetUserByCredentials(?, @user_id, @hashedPassword, @role_id); SELECT @user_id AS user_id, @hashedPassword AS password, @role_id AS role_id;",
        [user_name_or_email]
      );

      // Extract results from the second result set
      const user = result[1][0];

      if (!user || !user.user_id) {
        console.log("User not found in database");
        return next(errorProvider(401, "Invalid username or password"));
      }

      user_id = user.user_id;
      hashedPassword = user.password;
      role_id = user.role_id.toString();

      // Verify the password
      const isPasswordValid = await verifyPassword(password, hashedPassword);

      if (!isPasswordValid) {
        return next(errorProvider(401, "Invalid username or password"));
      }

      // Generate JWT token
      const token = jwt.sign({ user_id, role_id }, JWT_SECRET, {
        expiresIn: remember_me ? "2 days" : "1h",
      });

      // Send response
      return res
        .cookie("access-token", token, { httpOnly: true })
        .status(200)
        .json({ message: "Login successful" });
    } catch (error) {
      console.error("Error during login:", error);
      return next(errorProvider(500, "An error occurred during login"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const me = async (req, res, next) => {
  const { user_id, role_id } = req.user;
  const conn = await pool.getConnection();

  try {
    let procedureName;

    switch (role_id) {
      case "5":
        procedureName = "GetStudentDetails";
        break;
      case "4":
        procedureName = "GetManagerDetails";
        break;
      case "3":
        procedureName = "GetDepartmentDetails";
        break;
      case "2":
        procedureName = "GetFacultyDetails";
        break;
      case "1":
        procedureName = "GetAdminDetails";
        break;
      default:
        return next(errorProvider(400, "Invalid role ID"));
    }

    // Call the stored procedure
    const [userDetails] = await conn.query(`CALL ${procedureName}(?)`, [
      user_id,
    ]);

    // Respond with the first result
    return res.status(200).json(userDetails[0][0]);
  } catch (error) {
    console.error("Error fetching user details:", error);
    return next(
      errorProvider(500, "An error occurred while fetching user details")
    );
  } finally {
    // Release the connection
    if (conn) conn.release();
  }
};

export const logout = (req, res) => {
  try {
    res.cookie("access-token", "", {
      httpOnly: true,
      expires: new Date(0),
    });

    res.status(200).json({ message: "Logged out successfully" });
  } catch (error) {
    console.error("Error during logout:", error);
    res.status(500).json({ message: "Error during logout" });
  }
};

/*
export const studentRegister = async (req, res, next) => {
  const { user_name, name, f_id, email, status } = req.body;
  const role_id = 5;

  if (!user_name || !name || !f_id || !email || !status) {
    return next(errorProvider(400, "Missing credentials"));
  }

  try {
    const password = await generatePassword();
    // show the generated password for only login testing
    console.log("Generated password:", password);

    const hashedPassword = await hashPassword(password);

    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const [userExists] = await conn.execute(
        "SELECT COUNT(*) AS count FROM user WHERE user_name = ? OR email = ?",
        [user_name, email]
      );

      if (userExists[0].count > 0) {
        conn.release();
        return next(errorProvider(409, "User already exists"));
      }

      const [userResult] = await conn.execute(
        "INSERT INTO user(user_name, email, password, role_id) VALUES (?,?,?,?)",
        [user_name, email, hashedPassword, role_id]
      );
      const user_id = userResult.insertId;

      const [studentResult] = await conn.execute(
        "INSERT INTO student(user_id) VALUES (?)",
        [user_id]
      );
      const s_id = studentResult.insertId;

      await conn.execute(
        "INSERT INTO student_detail(s_id, name, f_id, status) VALUES (?,?,?,?)",
        [s_id, name, f_id, status]
      );

      await conn.commit();
      await mailer(email, user_name, password);

      return res
        .status(201)
        .json({ message: "Student registered successfully" });
    } catch (error) {
      await conn.rollback();
      return next(errorProvider(500, "User already exists"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during registration:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const managerRegister = async (req, res, next) => {
  const { user_name, name, email, contact_no, status } = req.body;
  const role_id = 4;

  if (!user_name || !name || !email || !contact_no || !status) {
    return next(errorProvider(400, "Missing credentials"));
  }

  try {
    const password = await generatePassword();

    console.log("Generated password:", password);
    const hashedPassword = await hashPassword(password);

    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const [userExists] = await conn.execute(
        "SELECT COUNT(*) AS count FROM user WHERE user_name = ? OR email = ?",
        [user_name, email]
      );

      if (userExists[0].count > 0) {
        conn.release();
        return next(errorProvider(409, "User already exists"));
      }

      const [userResult] = await conn.execute(
        "INSERT INTO user(user_name, email, password, role_id) VALUES (?,?,?,?)",
        [user_name, email, hashedPassword, role_id]
      );
      const user_id = userResult.insertId;

      const [managerResult] = await conn.execute(
        "INSERT INTO manager(user_id) VALUES (?)",
        [user_id]
      );
      const m_id = managerResult.insertId;

      await conn.execute(
        "INSERT INTO manager_detail(m_id, name, contact_no, status) VALUES (?,?,?,?)",
        [m_id, name, contact_no, status]
      );

      await conn.commit();
      await mailer(email, user_name, password);

      res.status(201).json({ message: "Manger registered successfully" });
    } catch (error) {
      await conn.rollback();
      return next(
        errorProvider(500, "An error occurred while registering manager")
      );
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during registration:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};


export const login = async (req, res, next) => {
  const { user_name_or_email, password, remember_me } = req.body;

  if (!user_name_or_email || !password) {
    return next(errorProvider(400, "Missing credentials"));
  }

  try {
    const conn = await pool.getConnection();

    try {
      const [user] = await conn.execute(
        "SELECT user_id, password, role_id FROM user WHERE user_name = ? OR email = ?",
        [user_name_or_email, user_name_or_email]
      );

      if (user.length == 0) {
        console.log("User not found in database");
        return next(errorProvider(401, "Invalid username or password"));
      }

      const { user_id, password: hashedPassword, role_id } = user[0];

      const isPasswordValid = await verifyPassword(password, hashedPassword);

      if (!isPasswordValid) {
        return next(errorProvider(401, "Invalid username or password"));
      }

      const token = jwt.sign({ user_id, role_id }, JWT_SECRET, {
        expiresIn: remember_me ? "2 days" : "1h",
      });

      return res
        .cookie("access-token", token, { httpOnly: true })
        .status(200)
        .json({ message: "Login successful" });
    } catch (error) {
      console.error("Error during login:", error);
      return next(errorProvider(500, "An error occurred during login"));
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
  }
};

export const me = async (req, res, next) => {
  const { user_id, role_id } = req.user;
  const conn = await pool.getConnection();

  try {
    await conn.beginTransaction();

    let query;
    let params;

    if (role_id == "5") {
      query =
        "SELECT u.email, u.user_name, sd.name, u.role_id FROM user u INNER JOIN student s ON u.user_id = s.user_id INNER JOIN student_detail sd ON s.s_id = sd.s_id WHERE u.user_id = ?";
      params = [user_id];
    } else if (role_id == "4") {
      query =
        "SELECT u.email, u.user_name, md.name, u.role_id FROM user u INNER JOIN manager m ON u.user_id = m.user_id INNER JOIN manager_detail md ON m.m_id = md.m_id WHERE u.user_id = ?";
      params = [user_id];
    } else if (role_id == "3") {
      query =
        "SELECT u.email, u.user_name, d.d_name as name, u.role_id FROM user u INNER JOIN department d ON u.user_id = d.user_id WHERE u.user_id = ?";
      params = [user_id];
    } else if (role_id == "2") {
      query =
        "SELECT u.email, u.user_name, f.f_name as name, u.role_id FROM user u INNER JOIN faculty f ON u.user_id = f.user_id WHERE u.user_id = ?";
      params = [user_id];
    } else if (role_id == "1") {
      query = "SELECT email, user_name, role_id FROM user WHERE user_id = ?";
      params = [user_id];
    }

    const [userDetails] = await conn.execute(query, params);
    await conn.commit();

    return res.status(200).json(userDetails[0]);
  } catch (error) {
    // Rollback only if transaction was started
    if (
      conn &&
      conn.connection &&
      conn.connection._protocol._queue.length > 0
    ) {
      await conn.rollback();
    }
    return next(
      errorProvider(500, "An error occurred while fetching user details")
    );
  } finally {
    // Release the connection
    if (conn) conn.release();
  }
};

export const logout = (req, res) => {
  try {
    res.cookie("access-token", "", {
      httpOnly: true,
      expires: new Date(0),
    });

    res.status(200).json({ message: "Logged out successfully" });
  } catch (error) {
    console.error("Error during logout:", error);
    res.status(500).json({ message: "Error during logout" });
  }
};
*/
