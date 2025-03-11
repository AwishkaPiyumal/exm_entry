import csv from "csv-parser";
import streamifier from "streamifier";
import pool from "../config/db.js";
import { generatePassword, hashPassword } from "../utils/functions.js";
import jwt from "jsonwebtoken";
import { verifyPassword } from "../utils/functions.js";
import errorProvider from "../utils/errorProvider.js";
import mailer from "../utils/mailer.js";
import path from "path";
import fs from "fs";
import crypto from "crypto";
import { dirname, join } from "path";
import { fileURLToPath } from "url";

const __dirname = dirname(fileURLToPath(import.meta.url));
const JWT_SECRET = process.env.JWT_SECRET || "abc123";
const FRONTEND_SERVER = process.env.FRONTEND_SERVER || "localhost";
const FRONTEND_PORT = process.env.FRONTEND_PORT || "3000";
const MAX_FAILED_ATTEMPTS = 10;
const LOCKOUT_DURATION_MINUTES = 15; // Lockout duration in minutes

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

      const [indexNoExistsResult] = await conn.query(
        "CALL CheckIndexNoExists(?, @indexNoExists); SELECT @indexNoExists AS indexNoExists;",
        [index_num]
      );
      const indexNoExists = indexNoExistsResult[1][0].indexNoExists;

      if (indexNoExists) {
        conn.release();
        return next(errorProvider(409, "Index no already exists"));
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

      let desc = `Student created with user_id=${user_id}, s_id=${s_id}, name=${name}, f_id=${f_id}, index_num=${index_num}, contact_no=${contact_no}`;

      await conn.query("CALL LogAdminAction(?);", [desc]);

      try {
        await mailer(
          email,
          "Registration succesfull",
          `<h2>You are successfully registered to examinations</h2>
                <h4>User name : ${user_name}</h4>
                <h4>Password : ${password}</h4>`
        );
      } catch (mailError) {
        console.error(`Failed to send mail:`, mailError);
      }

      await conn.commit();

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

export const multipleStudentsRegister = async (req, res, next) => {
  const results = [];
  const failedRecords = [];

  try {
    // Check if file exists
    if (!req.file || !req.file.buffer || !req.body.f_id) {
      return next(errorProvider(400, "No file uploaded"));
    }

    let f_id = req.body.f_id;

    const buffer = req.file.buffer; // Access the file buffer
    const stream = streamifier.createReadStream(buffer); // Convert buffer to readable stream

    // Parse CSV data
    stream
      .pipe(csv({ headers: true, skipLines: 1 })) // Read the file
      .on("data", (row) => {
        if (Object.keys(row).length) results.push(row); // Collect all rows
      })
      .on("end", async () => {
        const conn = await pool.getConnection();

        try {
          await conn.beginTransaction();
          for (const record of results) {
            const {
              _0: name,
              _1: user_name,
              _2: index_num,
              _3: email,
              _4: contact_no,
            } = record;

            // Validate fields
            if (!user_name || !name || !f_id || !email || !contact_no) {
              failedRecords.push({ record, error: "Missing credentials" });
              continue;
            }

            let status = "true";

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

            const [indexNoExistsResult] = await conn.query(
              "CALL CheckIndexNoExists(?, @indexNoExists); SELECT @indexNoExists AS indexNoExists;",
              [index_num]
            );
            const indexNoExists = indexNoExistsResult[1][0].indexNoExists;

            if (indexNoExists) {
              failedRecords.push({ record, error: "Index no already exists" });
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

            let desc = `Student created with user_id=${user_id}, s_id=${s_id}, name=${name}, f_id=${f_id}, index_num=${index_num}, contact_no=${contact_no}`;

            await conn.query("CALL LogAdminAction(?);", [desc]);

            try {
              await mailer(
                email,
                "Registration succesfull",
                `<h2>You are successfully registered to examinations</h2>
                <h4>User name : ${user_name}</h4>
                <h4>Password : ${password}</h4>`
              );
            } catch (mailError) {
              console.error(`Failed to send mail:`, mailError);
            }
          }

          await conn.commit();

          if (failedRecords.length > 0) {
            const filePath = path.join(__dirname, "failed_records.txt");
            const fileContent = failedRecords
              .map(
                (record) =>
                  `Name: ${record.record._0}\nUsername: ${record.record._1}\nIndex No: ${record.record._2}\nEmail: ${record.record._3}\nContact No: ${record.record._4}\nError: ${record.error}\n\n`
              )
              .join("");

            fs.writeFileSync(filePath, fileContent);

            res.setHeader(
              "Content-Disposition",
              `attachment; filename=failed_records.txt`
            );
            res.setHeader("Content-Type", "text/plain");

            // Stream the file directly to the response
            const fileStream = fs.createReadStream(filePath);
            fileStream.pipe(res);

            fileStream.on("end", () => {
              // Clean up the file after sending
              fs.unlinkSync(filePath);
            });

            return;
          }

          return res.status(201).json({
            message: "Students registered successfully",
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

      let desc = `Manager created with user_id=${user_id}, m_id=${m_id}, name=${name}, contact_no=${contact_no}`;
      await conn.query("CALL LogAdminAction(?);", [desc]);

      try {
        await mailer(
          email,
          "Registration succesfull",
          `<h2>You are successfully registered to examinations</h2>
          <h4>User name : ${user_name}</h4>
          <h4>Password : ${password}</h4>`
        );
      } catch (mailError) {
        console.error(`Failed to send mail:`, mailError);
      }
      await conn.commit();

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
  try {
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
  } catch (error) {
    console.error("Database connection error:", error);
    return next(errorProvider(500, "Failed to establish database connection"));
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

export const forgotPassword = async (req, res, next) => {
  const { emailOrUsername } = req.body;

  if (!emailOrUsername) {
    return res.status(400).json({ message: "Email or username is required." });
  }

  try {
    const conn = await pool.getConnection();
    try {
      const [user] = await conn.query(
        "SELECT user_id, email, failed_attempts, lockout_until FROM user WHERE email = ? OR user_name = ?",
        [emailOrUsername, emailOrUsername]
      );

      if (user.length === 0) {
        return res
          .status(404)
          .json({ message: "No user found with this email address." });
      }

      const { user_id, email, failed_attempts, lockout_until } = user[0];
      const currentTime = new Date();

      // Check if user is in the lockout period
      if (lockout_until && new Date(lockout_until) > currentTime) {
        const remainingTime = Math.ceil(
          (new Date(lockout_until) - currentTime) / (1000 * 60)
        );
        return res.status(429).json({
          message: `Too many reset attempts. Please try again in ${remainingTime} minutes.`,
        });
      }

      // Reset the counter if lockout period has passed
      if (lockout_until && new Date(lockout_until) <= currentTime) {
        await conn.query(
          "UPDATE user SET failed_attempts = 0, lockout_until = NULL WHERE user_id = ?",
          [user_id]
        );
      }

      // Check if the failed attempts exceed the limit
      if (failed_attempts > MAX_FAILED_ATTEMPTS) {
        const lockoutPeriod = new Date(
          currentTime.getTime() + LOCKOUT_DURATION_MINUTES * 60 * 1000
        ); // 15 minutes lockout
        await conn.query(
          "UPDATE user SET lockout_until = ? WHERE user_id = ?",
          [lockoutPeriod, user_id]
        );

        return res.status(429).json({
          message:
            "Too many reset attempts. Please try again after 15 minutes.",
        });
      }

      // Generate token
      const resetToken = crypto.randomBytes(32).toString("hex");
      const hashedToken = crypto
        .createHash("sha256")
        .update(resetToken)
        .digest("hex");
      const expirationTime = new Date(Date.now() + 15 * 60 * 1000); // 15 minutes from now

      // Store hashed token and expiration in DB
      await conn.query("CALL StoreResetToken(?, ?, ?);", [
        user_id,
        hashedToken,
        expirationTime,
      ]);

      // Increment the failed attempts count
      await conn.query(
        "UPDATE user SET failed_attempts = failed_attempts + 1 WHERE user_id = ?",
        [user_id]
      );

      // Send email
      const resetLink = `http://${FRONTEND_SERVER}:${FRONTEND_PORT}/reset-password?token=${resetToken}`;
      const htmlContent = `<p>You are receiving this email because you have requested a password reset for your account.</p>
                           <p>Please click on the following link to reset your password:</p>
                           <a href="${resetLink}">Reset Password</a>
                           <p>OR</p>
                           <p>Paste this into your browser to complete the process:</p>
                           <p>${resetLink}</p>
                           <p>This link will expire in 15 minutes.</p>
                           <p>If you didn't request this, please ignore this email.</p>`;
      await mailer(email, "Password Reset Request", htmlContent);

      res.status(200).json({
        message: "Password reset link sent to your email.",
      });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during forgot password:", error);
    next(new Error("Failed to process password reset request."));
  }
};

export const resetPassword = async (req, res, next) => {
  const { token, newPassword } = req.body;

  if (!token || !newPassword) {
    return res
      .status(400)
      .json({ message: "Token and new password are required." });
  }

  try {
    const conn = await pool.getConnection();
    try {
      const hashedToken = crypto
        .createHash("sha256")
        .update(token)
        .digest("hex");

      const [user] = await conn.query("CALL GetUserByResetToken(?)", [
        hashedToken,
      ]);

      if (user[0].length === 0) {
        return res
          .status(400)
          .json({ message: "Invalid or expired reset token." });
      }

      const user_id = user[0][0].user_id;

      const hashedPassword = await hashPassword(newPassword);

      // Update password and invalidate reset token
      await conn.query("CALL UpdateUserPassword(?, ?)", [
        user_id,
        hashedPassword,
      ]);

      res.status(200).json({ message: "Password reset successfully." });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during password reset:", error);
    next(new Error("Failed to reset password."));
  }
};

export const changePassword = async (req, res, next) => {
  const { user_id } = req.user; // Assumes JWT authentication
  const { currentPassword, newPassword } = req.body;

  if (!currentPassword || !newPassword) {
    return res
      .status(400)
      .json({ message: "Current and new passwords are required." });
  }

  try {
    const conn = await pool.getConnection();
    try {
      // Fetch current hashed password
      const [user] = await conn.query(
        "SELECT password FROM user WHERE user_id = ?",
        [user_id]
      );

      if (user.length === 0) {
        return res.status(404).json({ message: "User not found." });
      }

      const isValidPassword = await verifyPassword(
        currentPassword,
        user[0].password
      );

      if (!isValidPassword) {
        return res
          .status(401)
          .json({ message: "Current password is incorrect." });
      }

      // Update password
      const hashedPassword = await hashPassword(newPassword);
      await conn.query("CALL UpdateUserPassword(?, ?)", [
        user_id,
        hashedPassword,
      ]);

      res.status(200).json({ message: "Password changed successfully." });
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during password change:", error);
    next(new Error("Failed to change password."));
  }
};
