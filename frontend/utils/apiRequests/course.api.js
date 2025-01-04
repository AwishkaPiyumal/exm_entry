import axiosInstance from "@/lib/axiosInstance";

export const getAllFaculties = async () => {
  const response = await axiosInstance.get("/course/getAllFaculties");
  return response.data;
};

export const getAllFacultiesWithExtraDetails = async () => {
  const response = await axiosInstance.get(
    "/course/getAllFacultiesWithExtraDetails"
  );
  return response.data;
};

export const createFaculty = async (data) => {
  const response = await axiosInstance.post("/course/createFaculty", data);
  return response.data;
};

export const updateFacultyStatus = async (data) => {
  const response = await axiosInstance.put("/course/updateFacultyStatus", data);
  return response.data;
};

export const updateFaculty = async (data) => {
  const response = await axiosInstance.put("/course/updateFaculty", data);
  return response.data;
};

export const getFacultyById = async (f_id) => {
  const response = await axiosInstance.post("/course/getFacultyById", { f_id });
  return response.data;
};

export const getNoOfFaculty = async () => {
  const response = await axiosInstance.get("/course/getNoOfFaculty");
  return response.data;
};

///////////////////////////////
/////////////////////////////////
export const getDepartmentsByFacultyId = async (f_id) => {
  const response = await axiosInstance.post(
    "/course/getDepartmentsByFacultyId",
    { f_id }
  );
  return response.data;
};

export const getAllDepartments = async () => {
  const response = await axiosInstance.get("/course/getAllDepartments");
  return response.data;
};

export const getAllDepartmentsWithExtraDetails = async () => {
  const response = await axiosInstance.get(
    "/course/getAllDepartmentsWithExtraDetails"
  );
  return response.data;
};

export const createDepartment = async (data) => {
  const response = await axiosInstance.post("/course/createDepartment", data);
  return response.data;
};

export const updateDepartment = async (data) => {
  const response = await axiosInstance.put("/course/updateDepartment", data);
  return response.data;
};

export const updateDepartmentStatus = async (data) => {
  const response = await axiosInstance.put(
    "/course/updateDepartmentStatus",
    data
  );
  return response.data;
};

export const getDepartmentById = async (d_id) => {
  const response = await axiosInstance.post("/course/getDepartmentById", {
    d_id,
  });
  return response.data;
};

export const getNoOfDepartments = async () => {
  const response = await axiosInstance.get("/course/getNoOfDepartments");
  return response.data;
};

///////////////////////////
//////////////////////////
export const getAllDegrees = async () => {
  const response = await axiosInstance.get("/course/getAllDegrees");
  return response.data;
};

export const getAllDegreesWithExtraDetails = async () => {
  const response = await axiosInstance.get(
    "/course/getAllDegreesWithExtraDetails"
  );
  return response.data;
};

export const createDegree = async (data) => {
  const response = await axiosInstance.post("/course/createDegree", data);
  return response.data;
};

export const updateDegree = async (data) => {
  const response = await axiosInstance.put("/course/updateDegree", data);
  return response.data;
};

export const updateDegreeStatus = async (data) => {
  const response = await axiosInstance.put("/course/updateDegreeStatus", data);
  return response.data;
};

export const getDegreeById = async (deg_id) => {
  const response = await axiosInstance.post("/course/getDegreeById", {
    deg_id,
  });
  return response.data;
};

export const getDegreesByDepartmentId = async (d_id) => {
  const response = await axiosInstance.post(
    "/course/getDegreesByDepartmentId",
    { d_id }
  );

  return response.data;
};

export const getNoOfDegrees = async () => {
  const response = await axiosInstance.get("/course/getNoOfDegrees");
  return response.data;
};

export const getActiveFacultiesWithDepartmentsCount = async () => {
  const response = await axiosInstance.get(
    "/course/getActiveFacultiesWithDepartmentsCount"
  );
  return response.data;
};

export const getActiveDepartmentsInAFacultyWithDegreesCount = async (f_id) => {
  const response = await axiosInstance.post(
    "/course/getActiveDepartmentsInAFacultyWithDegreesCount",
    { f_id }
  );
  return response.data;
};

export const getActiveDegreesInADepartmentWithLevelsCount = async (d_id) => {
  const response = await axiosInstance.post(
    "/course/getActiveDegreesInADepartmentWithLevelsCount",
    { d_id }
  );
  return response.data;
};

export const getDegreeByShort = async (short) => {
  const response = await axiosInstance.post("/course/getDegreeByShort", {
    short,
  });

  return response.data;
};
