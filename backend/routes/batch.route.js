import express from "express";
import multer from "multer";
import {
  addStudentsToTheBatchTable,
  createBatch,
  getAllBatchDetails,
  getAllBatches,
  getBatchByFacultyId,
  getBatchById,
  getBatchFullDetails,
  getBatchTimePeriod,
  getBatchesByStudent,
  getNonBatchStudents,
  getNoOfBatches,
  getStudentsByBatchId,
  setBatchTimePeriod,
  updateBatch,
  updateBatchStatus,
  getAllBatchesForDepartment,
  getAllBatchesForFaculty,
  getDeadlinesForBatch,
  getAllActiveBatchesProgesses,
  getBatchOpenDate,
  uploadAttendanceSheet,
} from "../controllers/batch.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";

const upload = multer({ storage: multer.memoryStorage() });
const router = express.Router();

router.get("/getAllBatches", verifyUser(["1"]), getAllBatches);
router.get("/getAllBatchDetails", verifyUser(["1"]), getAllBatchDetails);
router.post("/createBatch", verifyUser(["1"]), createBatch);
router.get("/getNoOfBatches", getNoOfBatches);
router.get("/getBatchesByStudent", verifyUser(["5"]), getBatchesByStudent);
router.post(
  "/addStudentsToTheBatchTable",
  verifyUser(["1"]),
  addStudentsToTheBatchTable
);
router.post("/getStudentsByBatchId", verifyUser(["1"]), getStudentsByBatchId);
router.post("/getBatchById", verifyUser(["1"]), getBatchById);
router.post(
  "/getBatchByFacultyId",
  verifyUser(["1", "2"]),
  getBatchByFacultyId
);
router.put("/updateBatch", verifyUser(["1"]), updateBatch);
router.put("/updateBatchStatus", verifyUser(["1"]), updateBatchStatus);
router.put("/setBatchTimePeriod", verifyUser(["1"]), setBatchTimePeriod);
router.post("/getBatchTimePeriod", verifyUser(["1"]), getBatchTimePeriod);
router.post("/getNonBatchStudents", verifyUser(["1"]), getNonBatchStudents);
router.post(
  "/getBatchFullDetails",
  verifyUser(["1", "5"]),
  getBatchFullDetails
);
router.get(
  "/getAllBatchesForDepartment",
  verifyUser(["3"]),
  getAllBatchesForDepartment
);
router.get(
  "/getAllBatchesForFaculty",
  verifyUser(["2"]),
  getAllBatchesForFaculty
);
router.get(
  "/getAllActiveBatchesProgesses",
  verifyUser(["1"]),
  getAllActiveBatchesProgesses
);
router.post(
  "/getDeadlinesForBatch",
  verifyUser(["1", "2", "3", "4"]),
  getDeadlinesForBatch
);

router.post(
  "/getBatchOpenDate",
  verifyUser(["1", "2", "3", "4"]),
  getBatchOpenDate
);

router.post(
  "/uploadAttendanceSheet",
  verifyUser(["1"]),
  upload.single("file"),
  uploadAttendanceSheet
);

export default router;
