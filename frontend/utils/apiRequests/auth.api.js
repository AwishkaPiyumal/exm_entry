import axiosInstance from "@/lib/axiosInstance";
import axios from "axios";

export const managerRegister = async (data) => {
  const response = await axiosInstance.post("/auth/managerRegister", data);
  return response.data;
};

export const studentRegister = async (data) => {
  const response = await axiosInstance.post("/auth/studentRegister", data);
  return response.data;
};

export const MultipleStudentsRegister = async (data) => {
  const response = await axios.post(
    "http://localhost:8080/api1/auth/MultipleStudentsRegister",
    data,
    {
      headers: {
        "Content-Type": "multipart/form-data",
      },
      withCredentials: true,
    }
  );
  return response.data;
};
