"use client";

import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { Skeleton } from "@/components/ui/skeleton";
import { getAllBatchesForDepartment } from "@/utils/apiRequests/batch.api";
import { numberToOrdinalWord, parseString } from "@/utils/functions";
import { useQuery } from "@tanstack/react-query";
import Link from "next/link";
import { usePathname } from "next/navigation";

const HodHome = () => {
  const pathname = usePathname();

  const {
    data: batchesOfDepartmentData,
    isLoading: isBatchesOfDepartmenLoading,
  } = useQuery({
    queryFn: getAllBatchesForDepartment,
    queryKey: ["batchesOfDepartment"],
  });

  if (isBatchesOfDepartmenLoading)
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
        {batchesOfDepartmentData && batchesOfDepartmentData.length ? (
          batchesOfDepartmentData.map((obj) => {
            const level_ordinal = numberToOrdinalWord(obj.level);
            const sem_ordinal = numberToOrdinalWord(obj.sem);
            return (
              <Link
                href={{
                  pathname: `${pathname}/batches/${obj.batch_code}`,
                  query: {
                    batch_id: obj.batch_id,
                  },
                }}
                className="sm:w-[30%] sm:max-w-[30%] hover:shadow-md rounded-xl"
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
                </Card>
              </Link>
            );
          })
        ) : (
          <h1 className="text-2xl text-center w-full">No batches available!</h1>
        )}
      </div>
    </div>
  );
};

export default HodHome;
