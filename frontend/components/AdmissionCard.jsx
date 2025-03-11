"use client";
import React, { useEffect, useState } from "react";
import UoV_Logo from "./../images/UoV_Logo.png";
import Image from "next/image";
import parse from "html-react-parser";
import { FaCheck } from "react-icons/fa6";
import { FaTimes } from "react-icons/fa";

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

const AdmissionCard = ({
  student,
  type,
  level_ordinal,
  batchFullDetailsData,
  decodeBatchCode,
  formData,
  sem_ordinal,
  subjectObject,
  onRenderComplete,
}) => {
  useEffect(() => {
    if (onRenderComplete) {
      onRenderComplete();
    }
  }, [onRenderComplete]);

  return (
    <div className="p-4 pt-0 max-w-4xl mx-auto font-times bg-white">
      <div className="text-center mb-2 ">
        <Image
          src={UoV_Logo}
          alt="UOV logo"
          height={100}
          width={100}
          className="mx-auto mb-2"
        />
        <h1 className="font-bold text-lg uppercase leading-[1]">
          University of Vavuniya
        </h1>
        <h2 className="uppercase text-xl font-extrabold leading-[1]">
          faculty of {batchFullDetailsData?.f_name}
        </h2>
        <div className="flex justify-center font-semibold text-base uppercase space-x-2 items-center flex-wrap leading-[1]">
          {level_ordinal} examination in {batchFullDetailsData?.deg_name} -{" "}
          {decodeBatchCode.academic_year} - {sem_ordinal}&nbsp;semester -
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
        <h3 className="text-xl uppercase font-bold leading-[1.1]">
          Admission Card
        </h3>
      </div>

      <div className="flex justify-between mb-2 text-sm">
        <p>
          <span className="font-bold inline-block">Name</span> :&nbsp;
          {student?.name || ""}
        </p>
        <p>
          <span className="font-bold inline-block">Reg. No</span> :&nbsp;
          {student?.user_name || ""}
        </p>
        <p>
          <span className="font-bold inline-block">Index No</span> :&nbsp;
          {student?.index_num || ""}
        </p>
        <p>
          <span className="font-bold inline-block">Category</span> :&nbsp;
          {type == "P"
            ? "Proper"
            : type == "R"
            ? "Resit"
            : type == "M"
            ? "Medical"
            : ""}
        </p>
      </div>

      <div className="mb-5 mt-1 text-sm leading-[1.1]">
        {parse(formData.description) || ""}
      </div>

      <table className="w-full border-collapse border border-black mb-1">
        <thead>
          <tr>
            <th className="border border-black px-1 pb-2 text-xs">No.</th>
            <th className="border border-black px-1 pb-2 text-xs w-16">
              Subject Code
            </th>
            <th className="border border-black px-1 pb-2 text-xs w-72">
              Subject
            </th>
            <th className="border border-black px-1 pb-2 text-xs">Eligible</th>
            <th className="border border-black px-1 pb-2 text-xs w-16">Date</th>
            <th className="border border-black px-1 pb-2 text-xs">
              Candidate’s Signature
            </th>
            <th className="border border-black px-1 py-2 text-xs">
              Initials of Supervisor
            </th>
          </tr>
        </thead>
        <tbody>
          {Object.keys(student?.subjects).length &&
            formData.subjects.length &&
            formData.subjects.map((arr, ind) =>
              arr.map((subId, index) => (
                <tr key={index}>
                  <td className="border border-black text-center text-sm">
                    <div className="flex justify-center -mt-1 pb-2 items-center leading-[1]">
                      {index ? "" : ind + 1}
                    </div>
                  </td>
                  <td className="border border-black text-sm w-20">
                    <div className="flex items-center -mt-1 pb-2 leading-[1] pl-1">
                      {subjectObject[subId].sub_code}
                    </div>
                  </td>
                  <td className="border border-black text-sm w-80">
                    <div className="flex justify-start -mt-1 pb-2 items-center leading-[1] px-1">
                      {subjectObject[subId].sub_name}
                    </div>
                  </td>
                  <td className="border border-black p-1 pb-2 text-center text-sm">
                    <div className="flex justify-center items-center leading-[1]">
                      {student?.subjects.some((obj) => obj.sub_id == subId) &&
                      student?.subjects.filter((obj) => obj.sub_id == subId)[0]
                        .eligibility == "true" ? (
                        <FaCheck />
                      ) : (
                        <FaTimes />
                      )}
                    </div>
                  </td>
                  <td className="border border-black p-1 pb-2 text-center text-sm w-16"></td>
                  <td className="border border-black p-1 pb-2 text-sm"></td>
                  <td className="border border-black p-1 pb-2 text-sm"></td>
                </tr>
              ))
            )}
        </tbody>
      </table>

      {/* Footer Instructions */}
      <div className="mb-8">
        <div className="pl-2 text-sm">
          {parse(
            formData.instructions
              .replace(/<ol>/g, '<ol className="list-inside list-decimal">')
              .replace(/<ul>/g, '<ol className="list-inside list-disc">' || "")
              .replace(/<h3>/g, '<h3 className="text-lg">' || "")
              .replace(/<h2>/g, '<h2 className="text-2xl">' || "")
              .replace(/<h1>/g, '<h1 className="text-3xl">' || "")
          )}
        </div>
      </div>

      {/* Footer */}
      <div className="flex justify-end">
        <div className="text-left text-sm">
          {parse(formData.provider) || ""}
          {parse(formData.generated_date) || ""}
        </div>
      </div>
    </div>
  );
};

export default AdmissionCard;
