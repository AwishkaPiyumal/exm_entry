"use client";

import { useSearchParams } from "next/navigation";
import StudentDetails from "./StudentDetails";

const page = () => {
  const searchParams = useSearchParams();

  const sub_id = searchParams.get("sub_id");
  const batch_id = searchParams.get("batch_id");

  return (
    <div className="flex justify-end md:justify-center overflow-hidden">
      <div className="w-[80%] md:w-[85%] lg:w-[90%]">
        <StudentDetails sub_id={sub_id} batch_id={batch_id} />
      </div>
    </div>
  );
};

export default page;
