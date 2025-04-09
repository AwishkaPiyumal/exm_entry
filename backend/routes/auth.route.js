import express from "express";
// import rateLimit from "express-rate-limit";

import {
  studentRegister,
  managerRegister,
  login,
  me,
  logout,
  multipleStudentsRegister,
  resetPassword,
  forgotPassword,
  changePassword,
} from "../controllers/auth.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";
import multer from "multer";
const upload = multer({ storage: multer.memoryStorage() });

// const loginLimiter = rateLimit({
//   windowMs: 5 * 60 * 1000, // 5 minutes
//   max: 10, // limit to 10 login attempts per IP
//   message: "Too many login attempts. Try again in 5 minutes.",
// });

// const forgotLimiter = rateLimit({
//   windowMs: 15 * 60 * 1000,
//   max: 20,
//   message: "Too many forgot attempts. Try again in 15 minutes.",
// });

const router = express.Router();

router.post("/studentRegister", verifyUser(["1"]), studentRegister);
router.post(
  "/multipleStudentsRegister",
  verifyUser(["1"]),
  upload.single("file"),
  multipleStudentsRegister
);
router.post("/managerRegister", verifyUser(["1"]), managerRegister);
router.get("/me", verifyUser(["1", "2", "3", "4", "5"]), me);
router.post("/login", login);
// router.post("/login", loginLimiter, login);
router.post("/logout", logout);
router.post("/forgotPassword", forgotPassword);
// router.post("/forgotPassword", forgotLimiter, forgotPassword);
router.post("/resetPassword", resetPassword);
router.post(
  "/changePassword",
  verifyUser(["1", "2", "3", "4", "5"]),
  changePassword
);

export default router;
