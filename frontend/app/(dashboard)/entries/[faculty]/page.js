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
import { useQuery } from "@tanstack/react-query";
import { usePathname, useSearchParams } from "next/navigation";
import { getBatchByFacultyId } from "@/utils/apiRequests/batch.api";
import { useEffect, useState } from "react";
import { numberToOrdinalWord, parseString } from "@/utils/functions";
import { Skeleton } from "@/components/ui/skeleton";

const Faculties = () => {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const f_id = searchParams.get("f_id");

  const {
    data: batchesByFacultyData,
    isLoading: isBatchesByFacultyDataLoading,
  } = useQuery({
    queryFn: () => getBatchByFacultyId(f_id),
    queryKey: ["batchesByFaculty"],
  });

  if (isBatchesByFacultyDataLoading)
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
        {batchesByFacultyData &&
          batchesByFacultyData.map((obj) => {
            const level_ordinal = numberToOrdinalWord(obj.level);
            const sem_ordinal = numberToOrdinalWord(obj.sem);
            const endDate = new Date(obj.end_date);
            const now = new Date();
            return (
              <Link
                href={{
                  pathname: `${pathname}/${obj.batch_code}`,
                  query: {
                    batch_id: obj.batch_id,
                  },
                }}
                className="sm:w-[30%] sm:max-w-[30%] hover:shadow-md rounded-xl overflow-hidden"
                key={obj.batch_id}
              >
                <Card className="h-full flex flex-col justify-between">
                  <CardHeader>
                    <CardTitle className="uppercase text-center">
                      <p>
                        {level_ordinal} examination in {obj.deg_name}
                      </p>
                      <p>{obj.academic_year}</p>
                      <br />
                      <p>{sem_ordinal} semester</p>
                    </CardTitle>
                    <CardDescription className="uppercase text-center">
                      {obj.batch_code}
                    </CardDescription>
                  </CardHeader>
                  {endDate < now ? (
                    <CardFooter className="bg-green-500 uppercase flex justify-center items-center text-white pt-3">
                      Ready to print
                    </CardFooter>
                  ) : (
                    <CardFooter className="bg-red-500 flex justify-center items-center text-white pt-3 text-center">
                      {endDate
                        .toString()
                        .slice(4, endDate.toString().indexOf("GMT"))}
                    </CardFooter>
                  )}
                </Card>
              </Link>
            );
          })}
      </div>
    </div>
  );
};

export default Faculties;
