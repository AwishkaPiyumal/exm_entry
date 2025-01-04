import express from "express";
import {
  getCurriculumsByLecId,
  createCurriculum,
  updateCurriculum,
  getNoOfCurriculums,
  getAllCurriculums,
  getAllCurriculumsWithExtraDetails,
  getCurriculumById,
  getCurriculumByDegLevSem,
  getCurriculumBybatchId,
  getStudentApplicationDetails,
  getCurriculumsByDid,
  getAllSubjectsForManager,
  getAppliedStudentsForSubject,
  updateEligibility,
  updateCurriculumStatus,
} from "../controllers/curriculum.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";

const router = express.Router();

router.get("/getAllCurriculums", getAllCurriculums);
router.get(
  "/getAllCurriculumsWithExtraDetails",
  getAllCurriculumsWithExtraDetails
);
router.post("/getCurriculumById", getCurriculumById);
router.post("/getCurriculumByDegLevSem", getCurriculumByDegLevSem);
router.get("/getCurriculumsByLecId", getCurriculumsByLecId);
router.get("/getCurriculumsByHod_id", getCurriculumsByDid);
router.post("/createCurriculum", createCurriculum);
router.get(
  "/getStudentApplicationDetails",
  verifyUser(["5"]),
  getStudentApplicationDetails
);
router.post("/getCurriculumBybatchId", getCurriculumBybatchId);
router.put("/updateCurriculum", updateCurriculum);
router.put("/updateCurriculumStatus", updateCurriculumStatus);
router.get("/getNoOfCurriculums", getNoOfCurriculums);
router.get(
  "/getAllSubjectsForManager",
  verifyUser(["4"]),
  getAllSubjectsForManager
);
router.post(
  "/getAppliedStudentsForSubject",
  verifyUser(["1", "4"]),
  getAppliedStudentsForSubject
);
router.put("/updateEligibility", verifyUser(["1", "4"]), updateEligibility);

export default router;
