import axiosInstance from "@/lib/axiosInstance";
import axios from "axios";
const server = process.env.NEXT_PUBLIC_BACKEND_SERVER||"localhost";
const port = process.env.NEXT_PUBLIC_BACKEND_PORT||"8080";

export const managerRegister = async (data) => {
  const response = await axiosInstance.post("/auth/managerRegister", data);
  return response.data;
};

export const studentRegister = async (data) => {
  const response = await axiosInstance.post("/auth/studentRegister", data);
  return response.data;
};

export const multipleStudentsRegister = async (data) => {
  try {
    const response = await axios.post(
      `http://${server}:${port}/api1/auth/multipleStudentsRegister`,
      data,
      {
        headers: {
          "Content-Type": "multipart/form-data",
        },
        withCredentials: true,
        responseType: "blob", // Handle file responses
      }
    );

    const contentType = response.headers["content-type"];
    if (contentType.includes("application/json")) {
      // Handle JSON response
      const responseData = JSON.parse(await response.data.text());
      return { message: responseData.message, isFile: false };
    } else if (contentType.includes("text/plain")) {
      // Handle file response
      const url = window.URL.createObjectURL(new Blob([response.data]));
      const link = document.createElement("a");
      link.href = url;
      link.setAttribute("download", "failed_records.txt"); // File name for download
      document.body.appendChild(link);
      link.click();
      link.remove();

      return { message: "Failed records file downloaded.", isFile: true };
    }

    throw new Error("Unexpected response type");
  } catch (error) {
    console.error("Error processing request:", error);
    throw error;
  }
};

export const login = async (data) => {
  const response = await axiosInstance.post("/auth/login", data);
  return response.data;
};

export const forgotPassword = async (data) => {
  const response = await axiosInstance.post("/auth/forgotPassword", data);
  return response.data;
};

export const resetPassword = async (data) => {
  const response = await axiosInstance.post("/auth/resetPassword", data);
  return response.data;
};

export const changePassword = async (data) => {
  const response = await axiosInstance.post("/auth/changePassword", data);
  return response.data;
};
