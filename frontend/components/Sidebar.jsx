import Link from "next/link";
import { RiHome2Line } from "react-icons/ri";
import { LucideBook, LucideUser2 } from "lucide-react";
import { PiNotePencil, PiNoteDuotone } from "react-icons/pi";
import { useUser } from "@/utils/useUser";

const Sidebar = () => {
  const { data: user, isLoading } = useUser();

  return (
    user?.role_id == "1" && (
      <div className="w-12 hover:w-48 transition-all duration-300 overflow-hidden rounded-tr-xl rounded-br-xl fixed top-[50%] -translate-y-1/2 left-0 shadow-xl bg-white py-3 flex flex-col items-start bg-background/95 supports-[backdrop-filter]:bg-background/95 z-50">
        <Link
          href="/home"
          className="flex gap-3 uppercase items-center p-3 text-nowrap hover:bg-zinc-900 hover:text-zinc-100 w-[95%] rounded-r-md transition-colors duration-150"
        >
          <RiHome2Line size={25} className="shrink-0" />
          home
        </Link>

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
      </div>
    )
  );
};

export default Sidebar;
