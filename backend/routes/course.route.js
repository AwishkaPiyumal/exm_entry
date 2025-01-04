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

const router = express.Router();

////////FACULTY
router.post("/createFaculty", createFaculty);
router.put("/updateFaculty", updateFaculty);
router.put("/updateFacultyStatus", updateFacultyStatus);
router.get("/getAllFaculties", getAllFaculties);
router.post("/getFacultyById", getFacultyById);
router.get("/getNoOfFaculty", getNoOfFaculty);
router.post("/getNoOfDepartmentsByFaculty/:f_id", getNoOfDepartmentsByFaculty);
router.get("/getAllFacultiesWithExtraDetails", getAllFacultiesWithExtraDetails);
router.get(
  "/getActiveFacultiesWithDepartmentsCount",
  getActiveFacultiesWithDepartmentsCount
);

////////DEPARTMENT
router.post("/createDepartment", createDepartment);
router.put("/updateDepartment", updateDepartment);
router.put("/updateDepartmentStatus", updateDepartmentStatus);
router.get("/getAllDepartments", getAllDepartments);
router.post("/getDepartmentById", getDepartmentById);
router.post("/getDepartmentsByFacultyId", getDepartmentsByFacultyId);
router.get("/getNoOfDepartments", getNoOfDepartments);
router.post("/getNoOfDegreesByDepartment/:d_id", getNoOfDegreesByDepartment);
router.get(
  "/getAllDepartmentsWithExtraDetails",
  getAllDepartmentsWithExtraDetails
);
router.post(
  "/getActiveDepartmentsInAFacultyWithDegreesCount",
  getActiveDepartmentsInAFacultyWithDegreesCount
);
router.post(
  "/getActiveDegreesInADepartmentWithLevelsCount",
  getActiveDegreesInADepartmentWithLevelsCount
);

////////DEGREE
router.post("/createDegree", createDegree);
router.put("/updateDegree", updateDegree);
router.put("/updateDegreeStatus", updateDegreeStatus);
router.get("/getAllDegrees", getAllDegrees);
router.post("/getDegreeById", getDegreeById);
router.post("/getDegreesByDepartmentId", getDegreesByDepartmentId);
router.get("/getNoOfDegrees", getNoOfDegrees);
router.post("/getNoOfDegreesByLevel/:levels", getNoOfDegreesByLevel);
router.post("/getDegreeByShort", getDegreeByShort);
router.get("/getAllDegreesWithExtraDetails", getAllDegreesWithExtraDetails);
export default router;
