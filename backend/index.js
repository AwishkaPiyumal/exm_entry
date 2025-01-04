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

import { generatePassword, hashPassword } from "./utils/functions.js";
import pool from "./config/db.js";

dotenv.config();

const port = 8080;

const app = express();
app.use(express.json());
app.use(cookieParser());
app.use(
  cors({
    origin: "http://localhost:3000",
    credentials: true,
  })
);

const adminRegister = async () => {
  try {
    const password = "admin@123";
    const hashedPassword = await hashPassword(password);

    const conn = await pool.getConnection();

    try {
      await conn.beginTransaction();

      const [adminExists] = await conn.execute(
        "SELECT COUNT(*) AS count FROM user WHERE user_name = 'admin' OR email = 'admin@admin.com'"
      );

      if (adminExists[0].count == 0) {
        const [userResult] = await conn.execute(
          "INSERT INTO user(user_name, email, password, role_id) VALUES (?,?,?,?)",
          ["admin", "admin@admin.com", hashedPassword, "1"]
        );
        console.log(userResult);
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

app.listen(port, () => {
  console.log(`app is listening on port ${port}`);
});
