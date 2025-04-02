import axiosInstance from "@/lib/axiosInstance";

export const applyExam = async (removedSubjects) => {
  const response = await axiosInstance.put("/entry/applyExam", {
    removedSubjects,
  });
  return response.data;
};

export const getStudentSubjects = async (batch_id, s_id) => {
  const response = await axiosInstance.post("/entry/getStudentSubjects", {
    batch_id,
    s_id,
  });
  return response.data;
};

export const addMedicalResitStudents = async (data) => {
  const response = await axiosInstance.post(
    "/entry/addMedicalResitStudents",
    data
  );
  return response.data;
};

export const getStudentsWithoutIndexNumber = async (batch_id) => {
  const response = await axiosInstance.post(
    "/entry/getStudentsWithoutIndexNumber",
    {
      batch_id,
    }
  );
  return response.data;
};

export const generateIndexNumbers = async (data) => {
  const response = await axiosInstance.post(
    "/entry/generateIndexNumbers",
    data
  );
  return response.data;
};

export const getLastAssignedIndexNumber = async (data) => {
  const response = await axiosInstance.post(
    "/entry/getLastAssignedIndexNumber",
    data
  );
  return response.data;
};

export const createOrUpdateAdmission = async (data) => {
  const response = await axiosInstance.post(
    "/entry/createOrUpdateAdmission",
    data
  );
  return response.data;
};

export const getLatestAdmissionTemplate = async (batch_id) => {
  const response = await axiosInstance.post(
    "/entry/getLatestAdmissionTemplate",
    { batch_id }
  );
  return response.data;
};

export const fetchStudentsWithSubjects = async (batch_id) => {
  const response = await axiosInstance.post(
    "/entry/fetchStudentsWithSubjects",
    { batch_id }
  );
  return response.data;
};

export const getBatchAdmissionDetails = async (batch_id) => {
  const response = await axiosInstance.post("/entry/getBatchAdmissionDetails", {
    batch_id,
  });
  return response.data;
};

export const fetchStudentWithSubjectsByUserId = async (batch_id) => {
  const response = await axiosInstance.post(
    "/entry/fetchStudentWithSubjectsByUserId",
    {
      batch_id,
    }
  );
  return response.data;
};

export const getEligibleStudentsBySub = async (data) => {
  const response = await axiosInstance.post(
    "/entry/getEligibleStudentsBySub",
    data
  );
  return response.data;
};

export const createOrUpdateAttendance = async (data) => {
  const response = await axiosInstance.post(
    "/entry/createOrUpdateAttendance",
    data
  );
  return response.data;
};

export const getLatestAttendanceTemplate = async (batch_id) => {
  const response = await axiosInstance.post(
    "/entry/getLatestAttendanceTemplate",
    { batch_id }
  );
  return response.data;
};

export const deleteBatchSubjectEntries = async (batch_id) => {
  const response = await axiosInstance.post(
    "/entry/deleteBatchSubjectEntries",
    { batch_id }
  );
  return response.data;
};

export const getDeanDashboardData = async () => {
  const response = await axiosInstance.get("/entry/getDeanDashboardData");
  return response.data;
};

export const getHodDashboardData = async () => {
  const response = await axiosInstance.get("/entry/getHodDashboardData");
  return response.data;
};

export const getAppliedStudentsForSubject = async (batch_id, sub_id) => {
  const response = await axiosInstance.post(
    "/entry/getAppliedStudentsForSubject",
    { batch_id, sub_id }
  );
  return response.data;
};

export const getAppliedStudentsForSubjectOfFaculty = async (
  batch_id,
  sub_id
) => {
  const response = await axiosInstance.post(
    "/entry/getAppliedStudentsForSubjectOfFaculty",
    { batch_id, sub_id }
  );
  return response.data;
};

export const getAppliedStudentsForSubjectOfDepartment = async (
  batch_id,
  sub_id
) => {
  const response = await axiosInstance.post(
    "/entry/getAppliedStudentsForSubjectOfDepartment",
    { batch_id, sub_id }
  );
  return response.data;
};
