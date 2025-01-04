"use client";
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import Link from "next/link";
import { useQuery } from "@tanstack/react-query";
import { usePathname, useSearchParams } from "next/navigation";
import { getBatchByFacultyId } from "@/utils/apiRequests/batch.api";
import { useEffect, useState } from "react";
import { numberToOrdinalWord, parseString } from "@/utils/functions";

const faculties = () => {
  const pathname = usePathname();
  const searchParams = useSearchParams();

  const f_id = searchParams.get("f_id");

  const { data: batchesByFacultyData } = useQuery({
    queryFn: () => getBatchByFacultyId(f_id),
    queryKey: ["batchesByFaculty"],
  });

  return (
    <div className="flex justify-end md:justify-center">
      <div className="md:w-[70%] flex gap-6 flex-wrap">
        {batchesByFacultyData &&
          batchesByFacultyData.map((obj) => {
            const decodeBatchCode = parseString(obj.batch_code);
            const level_ordinal = numberToOrdinalWord(decodeBatchCode.level);
            const sem_ordinal = numberToOrdinalWord(decodeBatchCode.sem_no);
            return (
              <Link
                href={{
                  pathname: `${pathname}/${obj.batch_code}`,
                  query: {
                    batch_id: obj.batch_id,
                  },
                }}
                className="min-w-[30%] max-w-[30%] hover:shadow-md rounded-xl"
                key={obj.batch_id}
              >
                <Card>
                  <CardHeader>
                    <CardTitle className="capitalize text-center">
                      <p>
                        {level_ordinal} examination in {obj.deg_name}
                      </p>
                      <p>{decodeBatchCode.academic_year}</p>
                      <br />
                      <p>{sem_ordinal} semester</p>
                    </CardTitle>
                    <CardDescription className="capitalize text-center">
                      {obj.batch_code}
                    </CardDescription>
                  </CardHeader>
                </Card>
              </Link>
            );
          })}
      </div>
    </div>
  );
};

export default faculties;
