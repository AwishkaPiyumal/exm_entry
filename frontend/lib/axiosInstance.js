import axios from "axios";

const axiosInstance = axios.create({
  baseURL: `/api`,
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true,
});

export default axiosInstance;
