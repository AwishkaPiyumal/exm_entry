"use client";

import DashboardHeader from "@/components/DashboardHeader";
import Footer from "@/components/Footer";
import Sidebar from "@/components/Sidebar";
import axiosInstance from "@/lib/axiosInstance";
import { useRouter } from "next/navigation";

const RootLayout = ({ children }) => {
  const router = useRouter();

  const logoutHandler = async () => {
    try {
      const response = await axiosInstance.post("/auth/logout");

      window.location.href = "/";
      // router.push("/");
    } catch (error) {
      console.error("Logout failed:", error);
    }
  };

  return (
    <div className="min-h-full flex flex-col justify-between">
      <DashboardHeader logoutHandler={logoutHandler} />
      <Sidebar />
      <div className="p-3 pt-10 sm:pt-16 h-full w-full">{children}</div>
      <Footer />
    </div>
  );
};

export default RootLayout;
