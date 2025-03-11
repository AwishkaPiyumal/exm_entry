import express from "express";
import {
  addMedicalResitStudents,
  applyExam,
  createOrUpdateAdmission,
  createOrUpdateAttendance,
  deleteBatchSubjectEntries,
  fetchStudentsWithSubjects,
  fetchStudentWithSubjectsByUserId,
  generateIndexNumbers,
  getAppliedStudentsForSubject,
  getAppliedStudentsForSubjectOfDepartment,
  getAppliedStudentsForSubjectOfFaculty,
  getBatchAdmissionDetails,
  getDeanDashboardData,
  getEligibleStudentsBySub,
  getHodDashboardData,
  getLastAssignedIndexNumber,
  getLatestAdmissionTemplate,
  getLatestAttendanceTemplate,
  getStudentSubjects,
  getStudentsWithoutIndexNumber,
} from "../controllers/entry.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";

const router = express.Router();

router.put("/applyExam", verifyUser(["5"]), applyExam);
router.post("/getStudentSubjects", verifyUser(["1"]), getStudentSubjects);
router.post(
  "/addMedicalResitStudents",
  verifyUser(["1"]),
  addMedicalResitStudents
);
router.post(
  "/getStudentsWithoutIndexNumber",
  verifyUser(["1"]),
  getStudentsWithoutIndexNumber
);
router.post("/generateIndexNumbers", verifyUser(["1"]), generateIndexNumbers);
router.post(
  "/getLastAssignedIndexNumber",
  verifyUser(["1"]),
  getLastAssignedIndexNumber
);
router.post(
  "/createOrUpdateAdmission",
  verifyUser(["1"]),
  createOrUpdateAdmission
);
router.post(
  "/getLatestAdmissionTemplate",
  verifyUser(["1"]),
  getLatestAdmissionTemplate
);
router.post(
  "/fetchStudentsWithSubjects",
  verifyUser(["1"]),
  fetchStudentsWithSubjects
);
router.post(
  "/getBatchAdmissionDetails",
  verifyUser(["1", "5"]),
  getBatchAdmissionDetails
);
router.post(
  "/fetchStudentWithSubjectsByUserId",
  verifyUser(["5"]),
  fetchStudentWithSubjectsByUserId
);
router.post(
  "/getEligibleStudentsBySub",
  verifyUser(["1"]),
  getEligibleStudentsBySub
);
router.post(
  "/createOrUpdateAttendance",
  verifyUser(["1"]),
  createOrUpdateAttendance
);
router.post(
  "/getLatestAttendanceTemplate",
  verifyUser(["1"]),
  getLatestAttendanceTemplate
);
router.post(
  "/deleteBatchSubjectEntries",
  verifyUser(["1"]),
  deleteBatchSubjectEntries
);
router.get("/getDeanDashboardData", verifyUser(["2"]), getDeanDashboardData);
router.get("/getHodDashboardData", verifyUser(["3"]), getHodDashboardData);
router.post(
  "/getAppliedStudentsForSubject",
  verifyUser(["1", "4"]),
  getAppliedStudentsForSubject
);
router.post(
  "/getAppliedStudentsForSubjectOfFaculty",
  verifyUser(["2"]),
  getAppliedStudentsForSubjectOfFaculty
);
router.post(
  "/getAppliedStudentsForSubjectOfDepartment",
  verifyUser(["3"]),
  getAppliedStudentsForSubjectOfDepartment
);

export default router;
