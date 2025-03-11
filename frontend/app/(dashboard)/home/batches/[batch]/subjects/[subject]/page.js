"use client";

import { useSearchParams } from "next/navigation";
import StudentDetails from "./StudentDetails";

const page = () => {
  const searchParams = useSearchParams();

  const sub_id = searchParams.get("sub_id");
  const batch_id = searchParams.get("batch_id");

  return (
    <div className="flex justify-end md:justify-center">
      <div className="md:w-[70%] ">
        <StudentDetails sub_id={sub_id} batch_id={batch_id} />
      </div>
    </div>
  );
};

export default page;
