"use client";

import ReportTable from "@/components/ReportTable";
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import {
  getAllSubjectsForFaculty,
  getCurriculumBybatchId,
} from "@/utils/apiRequests/curriculum.api";
import {
  getDeanDashboardData,
  getHodDashboardData,
} from "@/utils/apiRequests/entry.api";
import { numberToOrdinalWord, parseString, titleCase } from "@/utils/functions";
import { useUser } from "@/utils/useUser";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { usePathname, useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import { Skeleton } from "@/components/ui/skeleton";

const Batches = () => {
  const [roleId, setRoleID] = useState(null);
  const { data: user } = useUser();
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const batch_id = searchParams.get("batch_id");

  useEffect(() => {
    if (user?.role_id) {
      setRoleID(user?.role_id);
    }
  }, [user]);

  const { data: subjectsOfBatchData, isLoading } = useQuery({
    queryFn: () => getCurriculumBybatchId(batch_id),
    queryKey: ["subjectsOfFaculty"],
  });

  if (isLoading)
    return (
      <div className="flex justify-end md:justify-center">
        <div className="w-[80%] md:w-[85%] lg:w-[70%] flex flex-col sm:flex-row gap-6 flex-wrap">
          {[1, 2, 3, 4, 5, 6].map((_, i) => (
            <Skeleton
              key={i}
              className="sm:w-[30%] h-32 sm:max-w-[30%] rounded-xl"
            />
          ))}
        </div>
      </div>
    );

  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[70%] flex flex-col sm:flex-row gap-6 flex-wrap">
        {subjectsOfBatchData && subjectsOfBatchData.length ? (
          subjectsOfBatchData.map((obj) => (
            <Link
              href={{
                pathname: `${pathname}/subjects/${obj.sub_code}`,
                query: {
                  sub_id: obj.sub_id,
                  batch_id,
                },
              }}
              className="sm:w-[30%] sm:max-w-[30%] hover:shadow-md rounded-xl"
              key={obj.sub_id}
            >
              <Card>
                <CardHeader>
                  <CardTitle>{titleCase(obj.sub_name)}</CardTitle>
                  <CardDescription>{obj.sub_code}</CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))
        ) : (
          <h1 className="text-2xl text-center w-full">
            No Subjects available!
          </h1>
        )}
      </div>
    </div>
  );
};

export default Batches;
