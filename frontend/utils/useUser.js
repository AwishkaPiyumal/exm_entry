import { useQuery } from "@tanstack/react-query";
import axiosInstance from "@/lib/axiosInstance";

export const useUser = () => {
  return useQuery({
    queryKey: ["user"],
    queryFn: async () => {
      const { data } = await axiosInstance.get("/auth/me");
      return data;
    },
  });
};
