"use client";
import { getAllActiveBatchesProgesses } from "@/utils/apiRequests/batch.api";
import { useQuery } from "@tanstack/react-query";
import SummaryCard from "./SummaryCard";
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import BatchProgress from "./BatchProgress";
import { getSummaryData } from "@/utils/apiRequests/user.api";
import { useState } from "react";

const AdminHome = () => {
  const [showMore, setShowMore] = useState(false);

  const { data: adminSummaryData } = useQuery({
    queryFn: getSummaryData,
    queryKey: ["adminSummary"],
  });

  const { data: allActiveBatchesProgessesData } = useQuery({
    queryFn: getAllActiveBatchesProgesses,
    queryKey: ["allActiveBatchesProgesses"],
  });

  return (
    <div className="flex justify-end md:justify-center">
      <div className="w-[80%] md:w-[85%] lg:w-[70%] flex flex-col sm:flex-row gap-6 flex-wrap">
        {adminSummaryData && (
          <div className="flex gap-6 flex-wrap items-center justify-center mb-8">
            <SummaryCard title={adminSummaryData.batch_count} desc="Batches" />
            <SummaryCard
              title={adminSummaryData.curriculum_count}
              desc="Curriculums"
            />
            <SummaryCard
              title={adminSummaryData.manager_count}
              desc="Managers"
            />
            <SummaryCard
              title={adminSummaryData.student_count}
              desc="Students"
            />
            <SummaryCard
              title={adminSummaryData.faculty_count}
              desc="Faculties"
            />
            <SummaryCard
              title={adminSummaryData.department_count}
              desc="Departments"
            />
            <SummaryCard title={adminSummaryData.degree_count} desc="Degrees" />
          </div>
        )}
        {allActiveBatchesProgessesData &&
          allActiveBatchesProgessesData.length && (
            <div className="container mx-auto mb-3">
              <h1 className="text-center text-3xl uppercase">
                A list of active batches
              </h1>
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead className="sm:w-[200px]">Batch</TableHead>
                    <TableHead className="text-center">Progress</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {allActiveBatchesProgessesData &&
                    allActiveBatchesProgessesData.length &&
                    (allActiveBatchesProgessesData.length > 5 && !showMore ? (
                      <>
                        {allActiveBatchesProgessesData
                          .slice(0, 5)
                          .map((obj, i) => {
                            if (obj.admission_id && obj.attendance_id) {
                              return (
                                <TableRow key={i}>
                                  <TableCell className="font-medium">
                                    {obj.batch_code}
                                  </TableCell>
                                  <TableCell>
                                    <BatchProgress task="done" />
                                  </TableCell>
                                </TableRow>
                              );
                            }

                            if (new Date() < new Date(obj.application_open)) {
                              return (
                                <TableRow key={i}>
                                  <TableCell className="font-medium">
                                    {obj.batch_code}
                                  </TableCell>
                                  <TableCell>
                                    <BatchProgress task="" />
                                  </TableCell>
                                </TableRow>
                              );
                            }

                            if (obj.btpData) {
                              const btpData = obj?.btp_data
                                ?.split(",")
                                .map((pair) => [
                                  pair.split(";")[0].trim(),
                                  pair.split(";")[1].trim(),
                                ]);

                              const deanDeadline = btpData.find(
                                (arr) => arr[0] == "2"
                              )[1];
                              if (new Date() > new Date(deanDeadline)) {
                                return (
                                  <TableRow key={i}>
                                    <TableCell className="font-medium">
                                      {obj.batch_code}
                                    </TableCell>
                                    <TableCell>
                                      <BatchProgress task="adm" />
                                    </TableCell>
                                  </TableRow>
                                );
                              }

                              const hodDeadline = btpData.find(
                                (arr) => arr[0] == "3"
                              )[1];
                              if (new Date() > new Date(hodDeadline)) {
                                return (
                                  <TableRow key={i}>
                                    <TableCell className="font-medium">
                                      {obj.batch_code}
                                    </TableCell>
                                    <TableCell>
                                      <BatchProgress task="dean" />
                                    </TableCell>
                                  </TableRow>
                                );
                              }

                              const lecDeadline = btpData.find(
                                (arr) => arr[0] == "4"
                              )[1];
                              if (new Date() > new Date(lecDeadline)) {
                                return (
                                  <TableRow key={i}>
                                    <TableCell className="font-medium">
                                      {obj.batch_code}
                                    </TableCell>
                                    <TableCell>
                                      <BatchProgress task="hod" />
                                    </TableCell>
                                  </TableRow>
                                );
                              }

                              const stuDeadline = btpData.find(
                                (arr) => arr[0] == "5"
                              )[1];
                              if (new Date() > new Date(stuDeadline)) {
                                return (
                                  <TableRow key={i}>
                                    <TableCell className="font-medium">
                                      {obj.batch_code}
                                    </TableCell>
                                    <TableCell>
                                      <BatchProgress task="lec" />
                                    </TableCell>
                                  </TableRow>
                                );
                              }

                              return (
                                <TableRow key={i}>
                                  <TableCell className="font-medium">
                                    {obj.batch_code}
                                  </TableCell>
                                  <TableCell>
                                    <BatchProgress task="stu" />
                                  </TableCell>
                                </TableRow>
                              );
                            }
                          })}
                        <TableRow>
                          <TableCell
                            className="cursor-pointer text-blue-600 inline-block"
                            onClick={() => setShowMore(true)}
                          >
                            Show more
                          </TableCell>
                        </TableRow>
                      </>
                    ) : (
                      <>
                        {allActiveBatchesProgessesData.map((obj, i) => {
                          if (obj.admission_id && obj.attendance_id) {
                            return (
                              <TableRow key={i}>
                                <TableCell className="font-medium">
                                  {obj.batch_code}
                                </TableCell>
                                <TableCell>
                                  <BatchProgress task="done" />
                                </TableCell>
                              </TableRow>
                            );
                          }

                          if (new Date() < new Date(obj.application_open)) {
                            return (
                              <TableRow key={i}>
                                <TableCell className="font-medium">
                                  {obj.batch_code}
                                </TableCell>
                                <TableCell>
                                  <BatchProgress task="" />
                                </TableCell>
                              </TableRow>
                            );
                          }

                          if (obj.btpData) {
                            const btpData = obj?.btp_data
                              ?.split(",")
                              .map((pair) => [
                                pair.split(";")[0].trim(),
                                pair.split(";")[1].trim(),
                              ]);

                            const deanDeadline = btpData.find(
                              (arr) => arr[0] == "2"
                            )[1];
                            if (new Date() > new Date(deanDeadline)) {
                              return (
                                <TableRow key={i}>
                                  <TableCell className="font-medium">
                                    {obj.batch_code}
                                  </TableCell>
                                  <TableCell>
                                    <BatchProgress task="adm" />
                                  </TableCell>
                                </TableRow>
                              );
                            }

                            const hodDeadline = btpData.find(
                              (arr) => arr[0] == "3"
                            )[1];
                            if (new Date() > new Date(hodDeadline)) {
                              return (
                                <TableRow key={i}>
                                  <TableCell className="font-medium">
                                    {obj.batch_code}
                                  </TableCell>
                                  <TableCell>
                                    <BatchProgress task="dean" />
                                  </TableCell>
                                </TableRow>
                              );
                            }

                            const lecDeadline = btpData.find(
                              (arr) => arr[0] == "4"
                            )[1];
                            if (new Date() > new Date(lecDeadline)) {
                              return (
                                <TableRow key={i}>
                                  <TableCell className="font-medium">
                                    {obj.batch_code}
                                  </TableCell>
                                  <TableCell>
                                    <BatchProgress task="hod" />
                                  </TableCell>
                                </TableRow>
                              );
                            }

                            const stuDeadline = btpData.find(
                              (arr) => arr[0] == "5"
                            )[1];
                            if (new Date() > new Date(stuDeadline)) {
                              return (
                                <TableRow key={i}>
                                  <TableCell className="font-medium">
                                    {obj.batch_code}
                                  </TableCell>
                                  <TableCell>
                                    <BatchProgress task="lec" />
                                  </TableCell>
                                </TableRow>
                              );
                            }

                            return (
                              <TableRow key={i}>
                                <TableCell className="font-medium">
                                  {obj.batch_code}
                                </TableCell>
                                <TableCell>
                                  <BatchProgress task="stu" />
                                </TableCell>
                              </TableRow>
                            );
                          }
                        })}
                        {allActiveBatchesProgessesData.length > 5 ? (
                          <TableRow>
                            <TableCell
                              className="cursor-pointer text-blue-600 inline-block"
                              onClick={() => setShowMore(false)}
                            >
                              Show less
                            </TableCell>
                          </TableRow>
                        ) : (
                          ""
                        )}
                      </>
                    ))}
                </TableBody>
              </Table>
            </div>
          )}
      </div>
    </div>
  );
};

export default AdminHome;
