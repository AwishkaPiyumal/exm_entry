import axiosInstance from "@/lib/axiosInstance";

export const getAllBatches = async () => {
  const response = await axiosInstance.get("/batch/getAllBatches");
  return response.data;
};

export const getAllBatchDetails = async () => {
  const response = await axiosInstance.get("/batch/getAllBatchDetails");
  return response.data;
};

export const getBatchById = async (batch_id) => {
  const response = await axiosInstance.post("/batch/getBatchById", {
    batch_id,
  });
  console.log(response.data);
  return response.data;
};

export const getStudentsByBatchId = async (batch_id) => {
  const response = await axiosInstance.post("/batch/getStudentsByBatchId", {
    batch_id,
  });
  return response.data;
};

export const createBatch = async (data) => {
  const response = await axiosInstance.post("/batch/createBatch", data);
  return response.data;
};

export const addStudentsToTheBatchTable = async (data) => {
  const response = await axiosInstance.post(
    "/batch/addStudentsToTheBatchTable",
    data
  );
  return response.data;
};

export const updateBatch = async (data) => {
  const response = await axiosInstance.put("/batch/updateBatch", data);
  return response.data;
};

export const updateBatchStatus = async (data) => {
  const response = await axiosInstance.put("/batch/updateBatchStatus", data);
  return response.data;
};

export const getNoOfBatches = async () => {
  const response = await axiosInstance.get("/batch/getNoOfBatches");
  return response.data;
};

export const getBatchByFacultyId = async (f_id) => {
  const response = await axiosInstance.post("/batch/getBatchByFacultyId", {
    f_id,
  });
  return response.data;
};

export const getBathchesByStudent = async () => {
  const response = await axiosInstance.get("/batch/getBathchesByStudent");
  console.log(response.data);
  return response.data;
};

export const setBatchTimePeriod = async (data) => {
  const response = await axiosInstance.put("/batch/setBatchTimePeriod", data);
  return response.data;
};

export const getBatchTimePeriod = async (batch_id) => {
  const response = await axiosInstance.post("/batch/getBatchTimePeriod", {
    batch_id,
  });
  return response.data;
};

export const getNonBatchStudents = async (batch_id) => {
  const response = await axiosInstance.post("/batch/getNonBatchStudents", {
    batch_id,
  });
  return response.data;
};

export const getBatchFullDetails = async (batch_id) => {
  const response = await axiosInstance.post("/batch/getBatchFullDetails", {
    batch_id,
  });
  return response.data;
};
