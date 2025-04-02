import express from "express";
import dotenv from "dotenv";
import cookieParser from "cookie-parser";
import cors from "cors";

import authRouter from "./routes/auth.route.js";
import userRoutes from "./routes/user.route.js";
import curriculumRouter from "./routes/curriculum.route.js";
import courseRouter from "./routes/course.route.js";
import batchRouter from "./routes/batch.route.js";
import entryRouter from "./routes/entry.route.js";

import { hashPassword } from "./utils/functions.js";
import pool from "./config/db.js";
import "./utils/cronScheduler.js";

dotenv.config();

const PORT = process.env.PORT;
const FRONTEND_SERVER = process.env.FRONTEND_SERVER;
const FRONTEND_PORT = process.env.FRONTEND_PORT;
const ADMIN_EMAIL = process.env.ADMIN_EMAIL;
const ADMIN_USERNAME = process.env.ADMIN_USERNAME;
const ADMIN_PASSWORD = process.env.ADMIN_PASSWORD;

const app = express();
app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: `http://${FRONTEND_SERVER}:${FRONTEND_PORT}`,
    credentials: true,
  })
);

const adminRegister = async () => {
  try {
    const hashedPassword = await hashPassword(ADMIN_PASSWORD);

    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const [adminExists] = await conn.execute(
        "SELECT COUNT(*) AS count FROM user WHERE user_name = ? OR email = ?",
        [ADMIN_USERNAME, ADMIN_EMAIL]
      );

      if (adminExists[0].count == 0) {
        const [userResult] = await conn.execute(
          "INSERT INTO user(user_name, email, password, role_id) VALUES (?,?,?,?)",
          [ADMIN_USERNAME, ADMIN_EMAIL, hashedPassword, "1"]
        );
        console.log("admin created");
      }

      await conn.commit();
      conn.release();
    } catch (error) {
      await conn.rollback();
    } finally {
      conn.release();
    }
  } catch (error) {
    console.error("Error during registration:", error);
  }
};

await adminRegister();

/////////ALL THE ROUTES
app.use("/api1/auth", authRouter);
app.use("/api1/user", userRoutes);
app.use("/api1/curriculum", curriculumRouter);
app.use("/api1/course", courseRouter);
app.use("/api1/batch", batchRouter);
app.use("/api1/entry", entryRouter);
///////////////////////////////////////////////////////////

app.use((err, req, res, next) => {
  const statuscode = err.statuscode;
  const message = err.message;
  console.log({
    success: false,
    message,
    statuscode,
  });
  return res.status(statuscode).json({
    success: false,
    message,
    statuscode,
  });
});

app.listen(PORT, () => {
  console.log(`app is listening on port ${PORT}`);
});
