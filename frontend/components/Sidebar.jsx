import Link from "next/link";
import { RiHome2Line } from "react-icons/ri";
import { LucideBook, LucideUser2 } from "lucide-react";
import { PiNotePencil, PiNoteDuotone } from "react-icons/pi";
import { useUser } from "@/utils/useUser";
import { useEffect, useState } from "react";
import { LuChartColumn } from "react-icons/lu";

const Sidebar = () => {
  const [roleId, setRoleID] = useState(null);
  const { data: user, isLoading } = useUser();

  useEffect(() => {
    if (user?.role_id) {
      setRoleID(user?.role_id);
    }
  }, [user]);

  return (
    (roleId == "1" || roleId == "2" || roleId == "3") && (
      <div className="w-12 hover:w-48 transition-all duration-300 overflow-hidden rounded-xl fixed top-[50%] left-2 -translate-y-1/2 shadow-2xl bg-white py-3 flex flex-col items-start bg-background supports-[backdrop-filter]:bg-background z-50">
        <Link
          href="/home"
          className="flex gap-3 uppercase items-center p-3 text-nowrap hover:bg-zinc-900 hover:text-zinc-100 w-[95%] rounded-r-md transition-colors duration-150"
        >
          <RiHome2Line size={25} className="shrink-0" />
          home
        </Link>

        {roleId !== "1" && (
          <Link
            href="/report"
            className="flex gap-3 uppercase items-center p-3 text-nowrap hover:bg-zinc-900 hover:text-zinc-100 w-[95%] rounded-r-md transition-colors duration-150"
          >
            <LuChartColumn size={23} className="shrink-0" />
            Report
          </Link>
        )}

        {roleId === "1" && (
          <>
            <Link
              href="/courses"
              className="flex gap-3 uppercase items-center p-3 text-nowrap hover:bg-zinc-900 hover:text-zinc-100 w-[95%] rounded-r-md transition-colors duration-150"
            >
              <LucideBook size={25} className="shrink-0" />
              Courses
            </Link>
            <Link
              href="/users"
              className="flex gap-3 uppercase items-center p-3 text-nowrap hover:bg-zinc-900 hover:text-zinc-100 w-[95%] rounded-r-md transition-colors duration-150"
            >
              <LucideUser2 size={25} className="shrink-0" />
              users
            </Link>
            <Link
              href="/examinations"
              className="flex gap-3 uppercase items-center p-3 text-nowrap hover:bg-zinc-900 hover:text-zinc-100 w-[95%] rounded-r-md transition-colors duration-150"
            >
              <PiNotePencil size={25} className="shrink-0" />
              Examinations
            </Link>
            <Link
              href="/entries"
              className="flex gap-3 uppercase items-center p-3 text-nowrap hover:bg-zinc-900 hover:text-zinc-100 w-[95%] rounded-r-md transition-colors duration-150"
            >
              <PiNoteDuotone size={25} className="shrink-0" />
              entry forms
            </Link>
          </>
        )}
      </div>
    )
  );
};

export default Sidebar;
