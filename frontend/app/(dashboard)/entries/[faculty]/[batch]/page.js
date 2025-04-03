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
import { useEffect, useRef, useState } from "react";
import { getCurriculumBybatchId } from "@/utils/apiRequests/curriculum.api";
import { Button } from "@/components/ui/button";
import { FaGear, FaPlus } from "react-icons/fa6";
import { TiWarning } from "react-icons/ti";
import Modal from "./Model";
import IndexModel from "./IndexModel";
import { getStudentsWithoutIndexNumber } from "@/utils/apiRequests/entry.api";
import { getDeadlinesForBatch } from "@/utils/apiRequests/batch.api";
import { Skeleton } from "@/components/ui/skeleton";

const Batches = () => {
  const pathname = usePathname();
  const searchParams = useSearchParams();
  const [isOpen, setIsOpen] = useState(false);
  const [isIndexOpen, setIsIndexOpen] = useState(false);
  const modalRef = useRef(null);
  const indexModalRef = useRef(null);
  const [endDate, setEndDate] = useState(null);

  const batch_id = searchParams.get("batch_id");

  const toggleModal = () => {
    setIsOpen((prev) => !prev);
  };

  const {
    data: curriculumsOfBatchData,
    isLoading: isCurriculumsOfBatchDataLoading,
  } = useQuery({
    queryFn: () => getCurriculumBybatchId(batch_id),
    queryKey: ["curriculumsOfBatch", batch_id],
  });

  const { data: deadlinesOfBatchData } = useQuery({
    queryFn: () => getDeadlinesForBatch(batch_id),
    queryKey: ["deadlinesOfBatch", batch_id],
  });

  const { data: studentsWithoutIndexNumberData } = useQuery({
    queryFn: () => getStudentsWithoutIndexNumber(batch_id),
    queryKey: ["studentsWithoutIndexNumber", batch_id],
  });

  const toggleIndexModal = () => {
    if (studentsWithoutIndexNumberData?.count) {
      setIsIndexOpen((prev) => !prev);
    }
  };

  useEffect(() => {
    if (deadlinesOfBatchData && deadlinesOfBatchData.length) {
      let end = new Date(
        deadlinesOfBatchData.find((obj) => obj.user_type == "2")?.deadline
      );

      setEndDate(end);
    }
  }, [deadlinesOfBatchData]);

  return (
    <div className="flex flex-col items-end md:items-center">
      <div
        className={`flex flex-col sm:flex-row items-center gap-2 sm:gap-0 sm:items-stretch self-stretch w-[80%] md:w-[85%] lg:w-[70%] mb-2 mx-auto justify-between`}
      >
        <Button onClick={toggleModal} variant="outline">
          <FaPlus />
          &nbsp;Insert Medical/Resit
        </Button>
        {deadlinesOfBatchData &&
          deadlinesOfBatchData.length &&
          endDate &&
          endDate < new Date() &&
          (studentsWithoutIndexNumberData?.count ? (
            <Button onClick={toggleIndexModal} variant="warning">
              Index Number Missing &nbsp;
              <TiWarning />
            </Button>
          ) : (
            <div className="flex space-x-3">
              <Link
                href={{
                  pathname: `${pathname}/admission`,
                  query: {
                    batch_id: batch_id,
                  },
                }}
                className="inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 bg-primary text-primary-foreground shadow hover:bg-primary/90 h-9 px-4 py-2"
              >
                Generate admission
              </Link>
            </div>
          ))}
      </div>
      <div className="w-[80%] md:w-[85%] lg:w-[70%] flex flex-col sm:flex-row gap-6 flex-wrap">
        {isCurriculumsOfBatchDataLoading &&
          [1, 2, 3, 4, 5, 6].map((_, i) => (
            <Skeleton
              key={i}
              className="sm:w-[30%] h-32 sm:max-w-[30%] rounded-xl"
            />
          ))}
        {curriculumsOfBatchData &&
          curriculumsOfBatchData.map((obj) => (
            <Link
              href={{
                pathname: `${pathname}/${obj.sub_code}`,
                query: {
                  sub_id: obj.sub_id,
                  sub_name: obj.sub_name,
                  sub_code: obj.sub_code,
                  batch_id: batch_id,
                },
              }}
              className="sm:w-[30%] sm:max-w-[30%] hover:shadow-md rounded-xl"
              key={obj.sub_id}
            >
              <Card className="h-full flex flex-col justify-between">
                <CardHeader>
                  <CardTitle className="uppercase text-wrap">
                    {obj.sub_name}
                  </CardTitle>
                  <CardDescription>{obj.sub_code}</CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))}
      </div>
      <Modal
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        modalRef={modalRef}
        curriculumsOfBatchData={curriculumsOfBatchData}
        batch_id={batch_id}
      />
      <IndexModel
        isIndexOpen={isIndexOpen}
        setIsIndexOpen={setIsIndexOpen}
        indexModalRef={indexModalRef}
        batch_id={batch_id}
        studentsWithoutIndexNumberData={studentsWithoutIndexNumberData}
      />
    </div>
  );
};

export default Batches;
