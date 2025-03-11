"use client";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { getNoOfManagers, getNoOfStudents } from "@/utils/apiRequests/user.api";

import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { usePathname } from "next/navigation";

const users = () => {
  const pathname = usePathname();
  const { data: noOfManagersData, isLoading: isNoOfManagersDataLoading } =
    useQuery({
      queryFn: getNoOfManagers,
      queryKey: ["noOfManagers"],
    });

  const { data: noOfStudentsData, isLoading: isNoOfStudentsDataLoading } =
    useQuery({
      queryFn: getNoOfStudents,
      queryKey: ["noOfStudents"],
    });

  if (isNoOfManagersDataLoading || isNoOfStudentsDataLoading)
    return (
      <div className="flex justify-end md:justify-center">
        <div className="md:w-[70%] flex gap-6 flex-wrap">
          {[1, 2].map((_, i) => (
            <Skeleton key={i} className="w-[30%] h-32 max-w-[30%] rounded-xl" />
          ))}
        </div>
      </div>
    );

  return (
    <div className="flex justify-end md:justify-center">
      <div className="md:w-[70%] flex gap-6 flex-wrap">
        <Link
          href={`${pathname}/managers`}
          className="min-w-[30%] max-w-[30%] hover:shadow-md rounded-xl"
        >
          <Card>
            <CardHeader>
              <CardTitle>Managers</CardTitle>
              <CardDescription>
                {noOfManagersData?.count} {noOfManagersData && "Managers"}
              </CardDescription>
            </CardHeader>
          </Card>
        </Link>

        <Link
          href={`${pathname}/students`}
          className="min-w-[30%] max-w-[30%] hover:shadow-md rounded-xl"
        >
          <Card>
            <CardHeader>
              <CardTitle>Students</CardTitle>
              <CardDescription>
                {noOfStudentsData?.count} {noOfStudentsData && "Students"}
              </CardDescription>
            </CardHeader>
          </Card>
        </Link>
      </div>
    </div>
  );
};

export default users;
