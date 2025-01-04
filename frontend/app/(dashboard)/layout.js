"use client";

import DashboardHeader from "@/components/DashboardHeader";
import Sidebar from "@/components/Sidebar";
import axiosInstance from "@/lib/axiosInstance";
import { useRouter } from "next/navigation";

const RootLayout = ({ children }) => {
  const router = useRouter();

  const logoutHandler = async () => {
    try {
      const response = await axiosInstance.post("/auth/logout");

      console.log(response.data.message);

      window.location.href = "/";
      // router.push("/");
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  return (
    <div>
      <DashboardHeader logoutHandler={logoutHandler} />
      <Sidebar />
      <div className="p-3 pt-16 h-full w-full">{children}</div>
    </div>
  );
};

export default RootLayout;
