"use client";
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { getNoOfBatches } from "@/utils/apiRequests/batch.api";
import { getNoOfCurriculums } from "@/utils/apiRequests/curriculum.api";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { usePathname } from "next/navigation";

const Examination = () => {
  const pathname = usePathname();
  const { data: noOfCurriculumsData, isLoading: isNoOfCurriculumsDataLoading } =
    useQuery({
      queryFn: getNoOfCurriculums,
      queryKey: ["noOfCurriculums"],
    });

  const { data: noOfBatchesData, isLoading: isNoOfBatchesDataLoading } =
    useQuery({
      queryFn: getNoOfBatches,
      queryKey: ["noOfBatches"],
    });

  if (isNoOfCurriculumsDataLoading || isNoOfBatchesDataLoading)
    return (
      <div className="flex justify-end md:justify-center">
        <div className="w-[80%] md:w-[85%] lg:w-[70%] flex flex-col sm:flex-row gap-6 flex-wrap">
          {[1, 2].map((_, i) => (
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
        <Link
          href={`${pathname}/curriculums`}
          className="sm:w-[30%] sm:max-w-[30%] hover:shadow-md rounded-xl"
        >
          <Card>
            <CardHeader>
              <CardTitle>Curriculums</CardTitle>
              <CardDescription>
                {noOfCurriculumsData?.count}{" "}
                {noOfCurriculumsData && "Curriculums"}
              </CardDescription>
            </CardHeader>
          </Card>
        </Link>
        <Link
          href={`${pathname}/batches`}
          className="sm:w-[30%] sm:max-w-[30%] hover:shadow-md rounded-xl"
        >
          <Card>
            <CardHeader>
              <CardTitle>Batches</CardTitle>
              <CardDescription>
                {noOfBatchesData?.count} {noOfBatchesData && "Batches"}
              </CardDescription>
            </CardHeader>
          </Card>
        </Link>
      </div>
    </div>
  );
};

export default Examination;
