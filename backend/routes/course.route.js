import express from "express";
import {
  createFaculty,
  updateFaculty,
  createDepartment,
  updateDepartment,
  createDegree,
  updateDegree,
  getAllFaculties,
  getFacultyById,
  getAllDepartments,
  getDepartmentById,
  getDegreeById,
  getAllDegrees,
  getDepartmentsByFacultyId,
  getDegreesByDepartmentId,
  getNoOfFaculty,
  getNoOfDepartments,
  getNoOfDegrees,
  getNoOfDepartmentsByFaculty,
  getNoOfDegreesByDepartment,
  getNoOfDegreesByLevel,
  getAllFacultiesWithExtraDetails,
  getAllDepartmentsWithExtraDetails,
  getAllDegreesWithExtraDetails,
  getActiveFacultiesWithDepartmentsCount,
  getActiveDepartmentsInAFacultyWithDegreesCount,
  getActiveDegreesInADepartmentWithLevelsCount,
  getDegreeByShort,
  updateDegreeStatus,
  updateDepartmentStatus,
  updateFacultyStatus,
} from "../controllers/course.controller.js";
import { verifyUser } from "../utils/verifyUsers.js";

const router = express.Router();

////////FACULTY
router.post("/createFaculty", verifyUser(["1"]), createFaculty);
router.put("/updateFaculty", verifyUser(["1"]), updateFaculty);
router.put("/updateFacultyStatus", verifyUser(["1"]), updateFacultyStatus);
router.get("/getAllFaculties", verifyUser(["1"]), getAllFaculties);
router.post("/getFacultyById", verifyUser(["1"]), getFacultyById);
router.get("/getNoOfFaculty", verifyUser(["1"]), getNoOfFaculty);
router.post(
  "/getNoOfDepartmentsByFaculty/:f_id",
  verifyUser(["1"]),
  getNoOfDepartmentsByFaculty
);
router.get(
  "/getAllFacultiesWithExtraDetails",
  verifyUser(["1"]),
  getAllFacultiesWithExtraDetails
);
router.get(
  "/getActiveFacultiesWithDepartmentsCount",
  verifyUser(["1"]),

  getActiveFacultiesWithDepartmentsCount
);

////////DEPARTMENT
router.post("/createDepartment", verifyUser(["1"]), createDepartment);
router.put("/updateDepartment", verifyUser(["1"]), updateDepartment);
router.put(
  "/updateDepartmentStatus",
  verifyUser(["1"]),
  updateDepartmentStatus
);
router.get("/getAllDepartments", verifyUser(["1"]), getAllDepartments);
router.post("/getDepartmentById", verifyUser(["1"]), getDepartmentById);
router.post(
  "/getDepartmentsByFacultyId",
  verifyUser(["1"]),
  getDepartmentsByFacultyId
);
router.get("/getNoOfDepartments", verifyUser(["1"]), getNoOfDepartments);
router.post(
  "/getNoOfDegreesByDepartment/:d_id",
  verifyUser(["1"]),
  getNoOfDegreesByDepartment
);
router.get(
  "/getAllDepartmentsWithExtraDetails",
  verifyUser(["1"]),

  getAllDepartmentsWithExtraDetails
);
router.post(
  "/getActiveDepartmentsInAFacultyWithDegreesCount",
  verifyUser(["1"]),

  getActiveDepartmentsInAFacultyWithDegreesCount
);
router.post(
  "/getActiveDegreesInADepartmentWithLevelsCount",
  verifyUser(["1"]),

  getActiveDegreesInADepartmentWithLevelsCount
);

////////DEGREE
router.post("/createDegree", verifyUser(["1"]), createDegree);
router.put("/updateDegree", verifyUser(["1"]), updateDegree);
router.put("/updateDegreeStatus", verifyUser(["1"]), updateDegreeStatus);
router.get("/getAllDegrees", verifyUser(["1"]), getAllDegrees);
router.post("/getDegreeById", verifyUser(["1"]), getDegreeById);
router.post(
  "/getDegreesByDepartmentId",
  verifyUser(["1"]),
  getDegreesByDepartmentId
);
router.get("/getNoOfDegrees", verifyUser(["1"]), getNoOfDegrees);
router.post(
  "/getNoOfDegreesByLevel/:levels",
  verifyUser(["1"]),
  getNoOfDegreesByLevel
);
router.post("/getDegreeByShort", verifyUser(["1"]), getDegreeByShort);
router.get(
  "/getAllDegreesWithExtraDetails",
  verifyUser(["1"]),
  getAllDegreesWithExtraDetails
);
export default router;
