"use client";

import { useRouter, useSearchParams } from "next/navigation";
import StudentDetails from "./StudentDetails";
import { useEffect, useState } from "react";
import { useQuery } from "@tanstack/react-query";
import { checkSubjectExist } from "@/utils/apiRequests/curriculum.api";
import { useUser } from "@/utils/useUser";

const page = () => {
  const searchParams = useSearchParams();
  const router = useRouter();
  const [roleId, setRoleID] = useState(null);
  const { data: user, isLoading } = useUser();

  useEffect(() => {
    if (user?.role_id) {
      setRoleID(user?.role_id);
    }
  }, [user]);

  const sub_id = searchParams.get("sub_id");
  const batch_id = searchParams.get("batch_id");

  const { data: subjectExistData } = useQuery({
    queryFn: () => checkSubjectExist({ batch_id, sub_id }),
    queryKey: ["subjectDataDetails", sub_id, batch_id],
    enabled: roleId == "4",
  });

  useEffect(() => {
    if (subjectExistData && !subjectExistData?.subjectExists) {
      router.push("/home");
    }
  }, [subjectExistData]);

  return (
    <div className="flex justify-end md:justify-center">
      <div className="md:w-[70%] ">
        <StudentDetails sub_id={sub_id} batch_id={batch_id} />
      </div>
    </div>
  );
};

export default page;
