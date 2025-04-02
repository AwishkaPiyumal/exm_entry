"use client";

import ReportTable from "@/components/ReportTable";
import Timeline from "@/components/Timeline";
import {
  getDeanDashboardData,
  getHodDashboardData,
} from "@/utils/apiRequests/entry.api";
import { numberToOrdinalWord, parseString } from "@/utils/functions";
import { useUser } from "@/utils/useUser";
import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";

const page = () => {
  const [roleId, setRoleID] = useState(null);
  const { data: user, isLoading } = useUser();

  useEffect(() => {
    if (user?.role_id) {
      setRoleID(user?.role_id);
    }
  }, [user]);

  const { data: dashboardData } = useQuery({
    queryFn:
      roleId == "2"
        ? getDeanDashboardData
        : roleId == "3"
        ? getHodDashboardData
        : null,
    queryKey: ["dashboard"],
    enabled: roleId == "2" || roleId == "3",
  });

  return (
    <div className="flex justify-end flex-col items-end gap-3">
      {dashboardData?.length ? (
        dashboardData.map((batch) => {
          const decodeBatchCode = parseString(batch.batch_code);
          const level_ordinal = numberToOrdinalWord(decodeBatchCode.level);
          const sem_ordinal = numberToOrdinalWord(decodeBatchCode.sem_no);
          const subjects = [];
          const properData = {};
          const medicalData = {};
          const resitData = {};
          batch.subjects.forEach((subObj) => {
            subjects.push({
              sub_id: subObj.sub_id,
              sub_code: subObj.sub_code,
            });
            subObj.students.forEach((stuObj) => {
              const remarks = subObj.remarks.filter(
                (remarkObj) => remarkObj.s_id == stuObj.s_id
              );
              if (stuObj.exam_type == "P") {
                properData[stuObj.index_num]
                  ? properData[stuObj.index_num].push({
                      sub_id: subObj.sub_id,
                      sub_code: subObj.sub_code,
                      eligibility: stuObj.eligibility,
                      remarks,
                    })
                  : (properData[stuObj.index_num] = [
                      {
                        sub_id: subObj.sub_id,
                        sub_code: subObj.sub_code,
                        eligibility: stuObj.eligibility,
                        remarks,
                      },
                    ]);
              } else if (stuObj.exam_type == "M") {
                medicalData[stuObj.index_num]
                  ? medicalData[stuObj.index_num].push({
                      sub_id: subObj.sub_id,
                      sub_code: subObj.sub_code,
                      eligibility: stuObj.eligibility,
                      remarks,
                    })
                  : (medicalData[stuObj.index_num] = [
                      {
                        sub_id: subObj.sub_id,
                        sub_code: subObj.sub_code,
                        eligibility: stuObj.eligibility,
                        remarks,
                      },
                    ]);
              } else if (stuObj.exam_type == "R") {
                resitData[stuObj.index_num]
                  ? resitData[stuObj.index_num].push({
                      sub_id: subObj.sub_id,
                      sub_code: subObj.sub_code,
                      eligibility: stuObj.eligibility,
                      remarks,
                    })
                  : (resitData[stuObj.index_num] = [
                      {
                        sub_id: subObj.sub_id,
                        sub_code: subObj.sub_code,
                        eligibility: stuObj.eligibility,
                        remarks,
                      },
                    ]);
              }
            });
          });

          return (
            <div
              key={batch.batch_id}
              className="w-[93%] border-4 border-zinc-500 p-3 rounded-lg"
            >
              <h1 className="uppercase text-2xl font-bold text-center my-3">
                {level_ordinal} examination in {batch.deg_name} -{" "}
                {decodeBatchCode.academic_year} - {sem_ordinal}
                &nbsp;semester
              </h1>
              <div>
                <h1 className="uppercase text-xl font-semibold text-center my-1 mt-6">
                  Proper
                </h1>
                <ReportTable
                  subjects={subjects}
                  data={properData}
                  exam_type="P"
                  batch_id={batch.batch_id}
                />

                <h1 className="uppercase text-xl font-semibold text-center my-1 mt-6">
                  Medical
                </h1>
                <ReportTable
                  subjects={subjects}
                  data={medicalData}
                  exam_type="M"
                  batch_id={batch.batch_id}
                />

                <h1 className="uppercase text-xl font-semibold text-center my-1 mt-6">
                  Re-sit
                </h1>
                <ReportTable
                  subjects={subjects}
                  data={resitData}
                  exam_type="R"
                  batch_id={batch.batch_id}
                />
              </div>
            </div>
          );
        })
      ) : (
        <h1 className="text-2xl text-center w-full">No reports available!</h1>
      )}
    </div>
  );
};

export default page;
