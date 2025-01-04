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

const entries = () => {
  const pathname = usePathname();
  const { data: noOfDepartmentsWithFacultyData } = useQuery({
    queryFn: getActiveFacultiesWithDepartmentsCount,
    queryKey: ["noOfDepartmentsWithFaculty"],
  });

  return (
    <div className="flex justify-end md:justify-center">
      <div className="md:w-[70%] flex gap-6 flex-wrap">
        {noOfDepartmentsWithFacultyData &&
          noOfDepartmentsWithFacultyData.map((obj) => (
            <Link
              href={{
                pathname: `${pathname}/${obj.f_name}`,
                query: {
                  f_id: obj.f_id,
                },
              }}
              className="min-w-[30%] max-w-[30%] hover:shadow-md rounded-xl"
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
