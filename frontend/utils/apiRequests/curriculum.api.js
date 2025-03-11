import axiosInstance from "@/lib/axiosInstance";

export const getAllCurriculums = async () => {
  const response = await axiosInstance.get("/curriculum/getAllCurriculums");
  return response.data;
};

export const getAllCurriculumsWithExtraDetails = async () => {
  const response = await axiosInstance.get(
    "/curriculum/getAllCurriculumsWithExtraDetails"
  );
  return response.data;
};

export const getCurriculumById = async (sub_id) => {
  const response = await axiosInstance.post("/curriculum/getCurriculumById", {
    sub_id,
  });
  return response.data;
};

export const getCurriculumByDegLevSem = async (deg_id, level, sem_no) => {
  const response = await axiosInstance.post(
    "/curriculum/getCurriculumByDegLevSem",
    {
      deg_id,
      level,
      sem_no,
    }
  );
  return response.data;
};

export const getCurriculumsByLecId = async () => {
  const response = await axiosInstance.get("/curriculum/getCurriculumsByLecId");
  return response.data;
};
export const getCurriculumsByHodId = async () => {
  const response = await axiosInstance.get("/curriculum/getCurriculumsByHodId");
  return response.data;
};
export const createCurriculum = async (data) => {
  const response = await axiosInstance.post(
    "/curriculum/createCurriculum",
    data
  );
  return response.data;
};

export const updateCurriculum = async (data) => {
  const response = await axiosInstance.put(
    "/curriculum/updateCurriculum",
    data
  );
  return response.data;
};

export const updateCurriculumStatus = async (data) => {
  const response = await axiosInstance.put(
    "/curriculum/updateCurriculumStatus",
    data
  );
  return response.data;
};

export const getNoOfCurriculums = async () => {
  const response = await axiosInstance.get("/curriculum/getNoOfCurriculums");
  return response.data;
};

export const getCurriculumBybatchId = async (batch_id) => {
  const response = await axiosInstance.post(
    "/curriculum/getCurriculumBybatchId",
    { batch_id }
  );
  return response.data;
};

export const getStudentApplicationDetails = async () => {
  const response = await axiosInstance.get(
    "/curriculum/getStudentApplicationDetails"
  );
  return response.data;
};

export const checkSubjectExist = async (data) => {
  const response = await axiosInstance.post(
    "/curriculum/checkSubjectExist",
    data
  );
  return response.data;
};

export const getAllSubjectsForManager = async () => {
  const response = await axiosInstance.get(
    "/curriculum/getAllSubjectsForManager"
  );
  return response.data;
};

export const getAllSubjectsForDepartment = async () => {
  const response = await axiosInstance.get(
    "/curriculum/getAllSubjectsForDepartment"
  );
  return response.data;
};

export const getAllSubjectsForFaculty = async () => {
  const response = await axiosInstance.get(
    "/curriculum/getAllSubjectsForFaculty"
  );
  return response.data;
};

export const updateEligibility = async (data) => {
  const response = await axiosInstance.put(
    "/curriculum/updateEligibility",
    data
  );
  return response.data;
};

export const updateMultipleEligibility = async (data) => {
  const response = await axiosInstance.put(
    "/curriculum/updateMultipleEligibility",
    data
  );
  return response.data;
};
