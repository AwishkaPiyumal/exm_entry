import express from "express";
import {
  getAllStudents,
  getAllManagers,
  updateStudent,
  updateManager,
  getManagerById,
  getStudentById,
  getNoOfManagers,
  getNoOfStudents,
  getAllActiveManagers,
  getStudentByDegShort,
  updateStudentStatus,
  updateManagerStatus,
  getSummaryData,
} from "../controllers/user.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";

const router = express.Router();

router.get("/getAllStudents", verifyUser(["1"]), getAllStudents);
router.get("/getAllManagers", verifyUser(["1"]), getAllManagers);

router.get("/getAllActiveManagers", verifyUser(["1"]), getAllActiveManagers);

router.post("/getManagerById", verifyUser(["1"]), getManagerById);
router.post("/getStudentById", verifyUser(["1"]), getStudentById);

router.put("/updateStudent", verifyUser(["1"]), updateStudent);
router.put("/updateStudentStatus", verifyUser(["1"]), updateStudentStatus);
router.put("/updateManager", verifyUser(["1"]), updateManager);
router.put("/updateManagerStatus", verifyUser(["1"]), updateManagerStatus);

router.get("/getNoOfManagers", verifyUser(["1"]), getNoOfManagers);
router.get("/getNoOfStudents", verifyUser(["1"]), getNoOfStudents);

router.get("/getSummaryData", verifyUser(["1"]), getSummaryData);

router.post("/getStudentByDegShort", verifyUser(["1"]), getStudentByDegShort);

export default router;
