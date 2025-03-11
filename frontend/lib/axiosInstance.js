import axios from "axios";

const server = process.env.NEXT_PUBLIC_BACKEND_SERVER||"localhost";
const port = process.env.NEXT_PUBLIC_BACKEND_PORT||"8080";

const axiosInstance = axios.create({
  baseURL: `http://${server}:${port}/api1`,
  headers: {
    "Content-Type": "application/json",
  },
  withCredentials: true,
});

export default axiosInstance;
