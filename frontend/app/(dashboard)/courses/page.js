"use client";
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import {
  getNoOfDegrees,
  getNoOfDepartments,
  getNoOfFaculty,
} from "@/utils/apiRequests/course.api";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { usePathname } from "next/navigation";

const users = () => {
  const pathname = usePathname();

  const { data: noOfFacultiesData, isLoading: isNoOfFacultiesDataLoading } =
    useQuery({
      queryFn: getNoOfFaculty,
      queryKey: ["noOfFaculties"],
    });

  const { data: noOfDepartmentsData, isLoading: isNoOfDepartmentsDataLoading } =
    useQuery({
      queryFn: getNoOfDepartments,
      queryKey: ["noOfDepartments"],
    });

  const { data: noOfDegreesData, isLoading: isNoOfDegreesDataLoading } =
    useQuery({
      queryFn: getNoOfDegrees,
      queryKey: ["noOfDegrees"],
    });

  if (
    isNoOfFacultiesDataLoading ||
    isNoOfDepartmentsDataLoading ||
    isNoOfDegreesDataLoading
  )
    return (
      <div className="flex justify-end md:justify-center">
        <div className="md:w-[70%] flex gap-6 flex-wrap">
          {[1, 2, 3].map((_, i) => (
            <Skeleton key={i} className="w-[30%] h-32 max-w-[30%] rounded-xl" />
          ))}
        </div>
      </div>
    );

  return (
    <div className="flex justify-end md:justify-center">
      <div className="md:w-[70%] flex gap-6 flex-wrap">
        <Link
          href={`${pathname}/faculties`}
          className="min-w-[30%] hover:shadow-md rounded-xl"
        >
          <Card>
            <CardHeader>
              <CardTitle>Faculties</CardTitle>
              <CardDescription>
                {noOfFacultiesData?.count} {noOfFacultiesData && "Faculties"}
              </CardDescription>
            </CardHeader>
          </Card>
        </Link>
        <Link
          href={`${pathname}/departments`}
          className="min-w-[30%] hover:shadow-md rounded-xl"
        >
          <Card>
            <CardHeader>
              <CardTitle>Departments</CardTitle>
              <CardDescription>
                {noOfDepartmentsData?.count}{" "}
                {noOfDepartmentsData && "Departments"}
              </CardDescription>
            </CardHeader>
          </Card>
        </Link>
        <Link
          href={`${pathname}/degree programmes`}
          className="min-w-[30%]  hover:shadow-md rounded-xl"
        >
          <Card>
            <CardHeader>
              <CardTitle>Degree programmes</CardTitle>
              <CardDescription>
                {noOfDegreesData?.count}{" "}
                {noOfDegreesData && "Degree programmes"}
              </CardDescription>
            </CardHeader>
          </Card>
        </Link>
      </div>
    </div>
  );
};

export default users;
