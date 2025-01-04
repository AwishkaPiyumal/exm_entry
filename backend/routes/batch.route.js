import express from "express";
import {
  addStudentsToTheBatchTable,
  createBatch,
  getAllBatchDetails,
  getAllBatches,
  getBatchByFacultyId,
  getBatchById,
  getBatchFullDetails,
  getBatchTimePeriod,
  getBathchesByStudent,
  getNonBatchStudents,
  getNoOfBatches,
  getStudentsByBatchId,
  setBatchTimePeriod,
  updateBatch,
  updateBatchStatus,
} from "../controllers/batch.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";

const router = express.Router();

router.get("/getAllBatches", verifyUser(["1"]), getAllBatches);
router.get("/getAllBatchDetails", verifyUser(["1"]), getAllBatchDetails);
router.post("/createBatch", verifyUser(["1"]), createBatch);
router.get("/getNoOfBatches", getNoOfBatches);
router.get("/getBathchesByStudent", verifyUser(["5"]), getBathchesByStudent);
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
router.post("/getBatchFullDetails", verifyUser(["1"]), getBatchFullDetails);

export default router;
