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
  updateEligibility,
  updateCurriculumStatus,
  updateMultipleEligibility,
  checkSubjectExist,
  getAllSubjectsForDepartment,
  getAllSubjectsForFaculty,
} from "../controllers/curriculum.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";

const router = express.Router();

router.get("/getAllCurriculums", verifyUser(["1"]), getAllCurriculums);
router.get(
  "/getAllCurriculumsWithExtraDetails",
  verifyUser(["1"]),

  getAllCurriculumsWithExtraDetails
);
router.post("/getCurriculumById", verifyUser(["1"]), getCurriculumById);
router.post(
  "/getCurriculumByDegLevSem",
  verifyUser(["1"]),
  getCurriculumByDegLevSem
);
router.get("/getCurriculumsByLecId", verifyUser(["1"]), getCurriculumsByLecId);
router.get("/getCurriculumsByHod_id", verifyUser(["1"]), getCurriculumsByDid);
router.post("/createCurriculum", verifyUser(["1"]), createCurriculum);
router.get(
  "/getStudentApplicationDetails",
  verifyUser(["5"]),
  getStudentApplicationDetails
);
router.post(
  "/getCurriculumBybatchId",
  verifyUser(["1", "2", "3", "4", "5"]),
  getCurriculumBybatchId
);
router.put("/updateCurriculum", verifyUser(["1"]), updateCurriculum);
router.put(
  "/updateCurriculumStatus",
  verifyUser(["1"]),
  updateCurriculumStatus
);
router.get("/getNoOfCurriculums", verifyUser(["1"]), getNoOfCurriculums);
router.get(
  "/getAllSubjectsForManager",
  verifyUser(["4"]),
  getAllSubjectsForManager
);
router.get(
  "/getAllSubjectsForDepartment",
  verifyUser(["3"]),
  getAllSubjectsForDepartment
);
router.get(
  "/getAllSubjectsForFaculty",
  verifyUser(["2"]),
  getAllSubjectsForFaculty
);

router.put(
  "/updateEligibility",
  verifyUser(["1", "2", "3", "4"]),
  updateEligibility
);
router.put(
  "/updateMultipleEligibility",
  verifyUser(["1", "2", "3", "4"]),
  updateMultipleEligibility
);
router.post("/checkSubjectExist", verifyUser(["4"]), checkSubjectExist);

export default router;
