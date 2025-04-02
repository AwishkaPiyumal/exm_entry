"use client";
import {
  Card,
  CardContent,
  CardDescription,
  CardFooter,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { useQuery } from "@tanstack/react-query";
import { getActiveFacultiesWithDepartmentsCount } from "@/utils/apiRequests/course.api";
import { Skeleton } from "@/components/ui/skeleton";

const entries = () => {
  const pathname = usePathname();
  const {
    data: noOfDepartmentsWithFacultyData,
    isLoading: isNoOfDepartmentsWithFacultyDataLoading,
  } = useQuery({
    queryFn: getActiveFacultiesWithDepartmentsCount,
    queryKey: ["noOfDepartmentsWithFaculty"],
  });

  if (isNoOfDepartmentsWithFacultyDataLoading)
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
        {noOfDepartmentsWithFacultyData &&
          noOfDepartmentsWithFacultyData.map((obj) => (
            <Link
              href={{
                pathname: `${pathname}/${obj.f_name}`,
                query: {
                  f_id: obj.f_id,
                },
              }}
              className="sm:w-[30%] sm:max-w-[30%] hover:shadow-md rounded-xl"
              key={obj.f_id}
            >
              <Card>
                <CardHeader>
                  <CardTitle className="capitalize">{obj.f_name}</CardTitle>
                  <CardDescription></CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))}
      </div>
    </div>
  );
};

export default entries;
