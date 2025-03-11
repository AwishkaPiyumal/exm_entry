"use client";
import React, { useEffect, useState } from "react";
import UoV_Logo from "./../images/UoV_Logo.png";
import Image from "next/image";
import parse from "html-react-parser";
import { FaCheck } from "react-icons/fa6";
import { FaTimes } from "react-icons/fa";
import { titleCase } from "@/utils/functions";

let months = {
  0: "January",
  1: "February",
  2: "March",
  3: "April",
  4: "May",
  5: "June",
  6: "July",
  7: "August",
  8: "September",
  9: "October",
  10: "November",
  11: "December",
};

function arrayPadEnd(array) {
  const arr = new Array(80 - array.length).fill(0);
  let final = [...array, ...arr];
  return final;
}

const AttendanceSheet = ({
  level_ordinal,
  batchFullDetailsData,
  decodeBatchCode,
  formData,
  sem_ordinal,
  onRenderComplete,
  sub_name,
  sub_code,
  pageArr,
  pageNo,
  groupNo,
  totalPages,
  totalGroups,
  totalStudents,
  studentsInTheGroup,
}) => {
  const [splittedArray, setSplittedArray] = useState([]);

  useEffect(() => {
    if (pageArr.length) {
      let arr = arrayPadEnd(pageArr);

      let final = [
        arr.slice(0, 16),
        arr.slice(16, 32),
        arr.slice(32, 48),
        arr.slice(48, 64),
        arr.slice(64),
      ];
      setSplittedArray(final);
    }
  }, [pageArr]);

  useEffect(() => {
    if (onRenderComplete && splittedArray.length) {
      onRenderComplete();
    }
  }, [onRenderComplete, splittedArray]);

  return (
    <div className="p-4 pt-0 max-w-4xl mx-auto font-times bg-white">
      {/* <div className="text-center mb-4"> */}
      <div className="flex justify-between items-center mb-2">
        <div className="flex">
          Page : {pageNo} of {totalPages}
        </div>
        <div className="flex items-center">
          <span>Hall&nbsp;No&nbsp;:&nbsp;</span>
          <div>{formData[groupNo]?.hallNo || ""}</div>
        </div>
      </div>
      <h1 className="font-bold text-lg uppercase text-center mb-2">
        University of Vavuniya
      </h1>
      <div className="flex mb-1">
        <div className="w-36 flex justify-between shrink-0">
          Examination <span>:&nbsp;</span>
        </div>
        <div className="flex flex-wrap items-center">
          {titleCase(
            `${level_ordinal} examination in ${batchFullDetailsData?.deg_name} - ${decodeBatchCode.academic_year} - ${sem_ordinal} semester -`
          )}
          &nbsp;
          {formData.date?.map((obj, ind) =>
            ind
              ? " ," +
                obj.months
                  .map((month, index) =>
                    index ? `/${months[month]}` : `${months[month]}`
                  )
                  .join("") +
                " " +
                obj.year
              : obj.months
                  .map((month, index) =>
                    index ? `/${months[month]}` : `${months[month]}`
                  )
                  .join("") +
                " " +
                obj.year
          )}
        </div>
      </div>
      <div className="flex mb-1">
        <div className="w-36 flex justify-between shrink-0">
          Subject <span>:&nbsp;</span>
        </div>
        <div>{sub_name}</div>
      </div>
      <div className="flex justify-between">
        <div className="flex flex-col gap-1">
          <div className="flex">
            <div className="w-36 flex justify-between shrink-0">
              Course unit no <span>:&nbsp;</span>
            </div>
            <div>{sub_code}</div>
          </div>
          <div className="flex items-center">
            <div className="w-36 flex justify-between shrink-0">
              Center <span>:&nbsp;</span>
            </div>
            <div>{formData[groupNo]?.center || ""}</div>
          </div>
          <div className="flex">
            <div className="w-36 flex justify-between shrink-0">
              Group no <span>:&nbsp;</span>
            </div>
            <div>
              {groupNo} of {totalGroups}
            </div>
          </div>
        </div>
        <div className="flex flex-col gap-1">
          <div className="flex items-center">
            <div className="w-36 flex justify-between shrink-0">
              Date <span>:&nbsp;</span>
            </div>
            <div>{formData[groupNo]?.actual_date || ""}</div>
          </div>
          <div className="flex items-center">
            <div className="w-36 flex justify-between shrink-0">
              Time <span>:&nbsp;</span>
            </div>
            <div className="flex items-center space-x-2">
              <div>{formData[groupNo]?.fromTime || ""}</div>
              <span>&ndash;</span>

              <div>{formData[groupNo]?.toTime || ""}</div>
            </div>
          </div>
          <div className="flex">
            <div className="w-36 flex justify-between shrink-0">
              Students count <span>:&nbsp;</span>
            </div>
            <div>
              {studentsInTheGroup} of {totalStudents}
            </div>
          </div>
        </div>
      </div>

      <h3 className="text-xl mt-1 uppercase text-center font-algerian">
        attendance list
      </h3>
      {/* </div> */}

      <div className="mb-2 text-base">{parse(formData.description) || ""}</div>

      <div className="flex">
        {[0, 1, 2, 3, 4].map((ele) => (
          <table
            key={ele}
            className="w-1/5 border-collapse border border-black text-sm mb-2"
          >
            <thead>
              <tr>
                <th className="border border-black px-1 py-3 font-semibold">
                  Index no
                </th>
                <th className="border border-black px-1 py-3 font-semibold">
                  Attendance
                </th>
              </tr>
            </thead>
            <tbody>
              {splittedArray[ele]?.map((obj, i) => (
                <tr className="h-[34px]" key={ele + "" + i}>
                  <td className="border border-black">
                    {obj ? (
                      typeof obj == "string" ? (
                        obj == "R" ? (
                          <h1 className="font-semibold text-center">Resit</h1>
                        ) : (
                          <h1 className="font-semibold text-center">Medical</h1>
                        )
                      ) : (
                        <h1
                          className={`text-center text-wrap ${
                            obj.index_num ? "" : "bg-red-500"
                          }`}
                        >
                          {obj.index_num || "Index no missing"}
                        </h1>
                      )
                    ) : (
                      ""
                    )}
                  </td>
                  <td className="border border-black "></td>
                </tr>
              ))}
            </tbody>
          </table>
        ))}
      </div>

      {/* Footer */}
      <div className="flex justify-between mt-4">
        <div className="flex flex-col space-y-2">
          <div className="flex">
            <span className="inline-block w-28">Center</span>
            &#58;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;
          </div>
          <div className="flex">
            <span className="inline-block w-28">Date</span>
            &#58;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;
          </div>
        </div>{" "}
        <div className="flex flex-col space-y-2">
          <div className="flex">
            <span className="inline-block w-28">Supervisor</span>
            &#58;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;
          </div>
          <div className="flex">
            <span className="inline-block w-28">Invigilators</span>
            &#58;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;&#46;
          </div>
        </div>
      </div>
    </div>
  );
};

export default AttendanceSheet;
