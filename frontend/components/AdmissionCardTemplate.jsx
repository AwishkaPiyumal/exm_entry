"use client";
import React, { useEffect, useState } from "react";
import UoV_Logo from "./../images/UoV_Logo.png";
import Image from "next/image";
import { useQuery } from "@tanstack/react-query";
import { getBatchFullDetails } from "@/utils/apiRequests/batch.api";
import { numberToOrdinalWord, parseString } from "@/utils/functions";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { FaTimes } from "react-icons/fa";
import { FaPlus } from "react-icons/fa6";
import { Button } from "./ui/button";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { getCurriculumBybatchId } from "@/utils/apiRequests/curriculum.api";

function getCurrentDate() {
  const today = new Date();
  const day = String(today.getDate()).padStart(2, "0");
  const month = String(today.getMonth() + 1).padStart(2, "0"); // Months are 0-indexed
  const year = today.getFullYear();

  return `${day}.${month}.${year}`;
}

function createSubjectObject(subjects) {
  const subjectMap = {};

  subjects?.forEach((subject) => {
    subjectMap[subject.sub_id] = subject;
  });

  return subjectMap;
}

const AdmissionCardTemplate = ({ batch_id }) => {
  const [formData, setFormData] = useState({
    generated_date: getCurrentDate(),
    subjects: [],
    date: [{ year: new Date().getFullYear(), months: [new Date().getMonth()] }],
  });
  const [level_ordinal, setLevel_ordinal] = useState("");
  const [sem_ordinal, setSem_ordinal] = useState("");
  const [decodeBatchCode, setDecodeBatchCode] = useState({});
  const [subjectObject, setSubjectObject] = useState({});

  const {
    data: batchFullDetailsData,
    isLoading,
    error,
  } = useQuery({
    queryFn: () => getBatchFullDetails(batch_id),
    queryKey: ["batchFullDetails"],
  });

  const { data: batchCurriculumData } = useQuery({
    queryFn: () => getCurriculumBybatchId(batch_id),
    queryKey: ["batchCurriculums"],
  });

  const studentDetails = {};
  const subjects = [];
  const subjectsDetails = {};
  const issueDate = "";

  const handleMonthChange = (month, yearIndex, monthIndex) => {
    setFormData((cur) => {
      const updatedDates = [...cur.date];
      updatedDates[yearIndex].months[monthIndex] = month;
      return { ...cur, date: updatedDates };
    });
  };

  const addNewMonth = (yearIndex) => {
    const monthsLength = formData?.date[yearIndex]?.months?.length;
    setFormData((cur) => {
      const updatedDates = [...cur.date];

      if (
        updatedDates[yearIndex]?.months &&
        updatedDates[yearIndex]?.months.length < monthsLength + 1
      ) {
        let lastItem =
          updatedDates[yearIndex].months[
            updatedDates[yearIndex].months.length - 1
          ];
        updatedDates[yearIndex].months.push(lastItem == 11 ? 0 : +lastItem + 1);
      }
      return { ...cur, date: updatedDates };
    });
  };

  const handleYearChange = (e, yearIndex) => {
    const year = e.target.value;
    setFormData((cur) => {
      const updatedDates = [...cur.date];
      updatedDates[yearIndex].year = year;
      return { ...cur, date: updatedDates };
    });
  };

  const addNewYearBlock = () => {
    setFormData((cur) => {
      let lastYear = cur.date[cur.date.length - 1].year;

      return {
        ...cur,
        date: [...cur.date, { year: +lastYear + 1, months: [0] }],
      };
    });
  };

  const removeYearBlock = (yearIndex) => {
    setFormData((cur) => {
      const updatedDates = [...cur.date];
      updatedDates.splice(yearIndex, 1);
      return { ...cur, date: updatedDates };
    });
  };

  const removeMonth = (yearIndex, monthIndex) => {
    setFormData((cur) => {
      const updatedDates = [...cur.date];
      updatedDates[yearIndex].months.splice(monthIndex, 1);
      return { ...cur, date: updatedDates };
    });
  };

  const onYearBlured = (e, yearIndex) => {
    let value = +e.target.value;
    if (value < +e.target.min) {
      value = +e.target.min;
    } else if (value > +e.target.max) {
      value = +e.target.max;
    }

    setFormData((cur) => {
      const updatedDates = [...cur.date];
      updatedDates[yearIndex].year = value;
      return { ...cur, date: updatedDates };
    });
    e.target.value = value;
  };

  useEffect(() => {
    if (batchFullDetailsData) {
      setDecodeBatchCode(parseString(batchFullDetailsData.batch_code));
    }
  }, [batchFullDetailsData]);

  useEffect(() => {
    if (decodeBatchCode) {
      setLevel_ordinal(numberToOrdinalWord(decodeBatchCode.level));
      setSem_ordinal(numberToOrdinalWord(decodeBatchCode.sem_no));
    }
  }, [decodeBatchCode]);

  useEffect(() => {
    console.log(formData);
  }, [formData]);

  useEffect(() => {
    console.log(batchCurriculumData);
    setSubjectObject(createSubjectObject(batchCurriculumData));
  }, [batchCurriculumData]);

  return (
    <div className="border-2 border-black p-8 max-w-4xl mx-auto font-serif bg-white">
      <div className="text-center mb-4">
        <Image
          src={UoV_Logo}
          alt="UOV logo"
          height={100}
          width={100}
          className="mx-auto"
        />
        <h1 className="font-bold text-lg uppercase underline">
          University of Vavuniya
        </h1>
        <h2 className="text-md uppercase text-xl font-extrabold">
          Faculty of Applied Science
        </h2>
        <h3 className="font-bold text-lg mt-2 uppercase">
          {level_ordinal} examination in {batchFullDetailsData?.deg_name} -
          {decodeBatchCode.academic_year} - <br />
        </h3>
        <div className="flex justify-center font-bold text-lg uppercase space-x-2 items-center flex-wrap">
          {sem_ordinal}
          &nbsp;semester -&nbsp;{" "}
          {formData.date.map((yearBlock, yearIndex) => (
            <React.Fragment key={yearIndex}>
              <span>
                {formData.date.length > 1 && (yearIndex || "") && ","}
              </span>
              <div key={yearIndex} className="flex space-x-3">
                <div className="flex items-center space-x-2">
                  {yearBlock.months.map((month, monthIndex) => (
                    <div
                      key={monthIndex}
                      className="flex items-center space-x-1"
                    >
                      {yearBlock.months.length > 1 && (monthIndex || "") && (
                        <span> &#47;</span>
                      )}
                      <Select
                        onValueChange={(selectedMonth) =>
                          handleMonthChange(
                            selectedMonth,
                            yearIndex,
                            monthIndex
                          )
                        }
                        value={month}
                      >
                        <SelectTrigger className="w-32 h-8">
                          <SelectValue placeholder="Month" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectGroup>
                            <SelectLabel>Months</SelectLabel>
                            {[
                              "January",
                              "February",
                              "March",
                              "April",
                              "May",
                              "June",
                              "July",
                              "August",
                              "September",
                              "October",
                              "November",
                              "December",
                            ].map((m, i) => (
                              <SelectItem key={i} value={i}>
                                {m}
                              </SelectItem>
                            ))}
                          </SelectGroup>
                        </SelectContent>
                      </Select>

                      {yearBlock.months.length > 1 && (monthIndex || "") && (
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => removeMonth(yearIndex, monthIndex)}
                          className="text-red-500 text-xs rounded-full size-6 p-0"
                        >
                          <FaTimes />
                        </Button>
                      )}
                    </div>
                  ))}

                  <TooltipProvider>
                    <Tooltip>
                      <TooltipTrigger
                        onClick={() => addNewMonth(yearIndex)}
                        className="inline-flex items-center justify-center gap-2 whitespace-nowrap font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 bg-primary text-primary-foreground shadow hover:bg-primary/90 text-xs rounded-full size-6 p-0"
                      >
                        <FaPlus />
                      </TooltipTrigger>
                      <TooltipContent>
                        <p>Add a month</p>
                      </TooltipContent>
                    </Tooltip>
                  </TooltipProvider>
                </div>
                <div className="flex items-center space-x-2">
                  <input
                    type="number"
                    min={new Date().getFullYear()}
                    max="2100"
                    placeholder="Year"
                    className="w-20 rounded-md border px-2 py-1 text-sm h-8"
                    value={yearBlock.year}
                    onChange={(e) => handleYearChange(e, yearIndex)}
                    onBlur={(e) => onYearBlured(e, yearIndex)}
                    autoFocus={true}
                  />

                  {yearIndex ? (
                    <Button
                      variant="outline"
                      size="sm"
                      onClick={() => removeYearBlock(yearIndex)}
                      className="text-red-500 text-xs rounded-full size-6 p-0"
                    >
                      <FaTimes />
                    </Button>
                  ) : (
                    ""
                  )}
                </div>
              </div>
            </React.Fragment>
          ))}
          <TooltipProvider>
            <Tooltip>
              <TooltipTrigger
                onClick={addNewYearBlock}
                className="inline-flex items-center justify-center gap-2 whitespace-nowrap font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none disabled:opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 bg-primary text-primary-foreground shadow hover:bg-primary/90 text-xs rounded-full size-6 p-0"
              >
                <FaPlus />
              </TooltipTrigger>
              <TooltipContent>
                <p>Add a month of another year</p>
              </TooltipContent>
            </Tooltip>
          </TooltipProvider>
        </div>
        <h3 className="font-bold text-lg mt-1">Admission Card</h3>
      </div>

      <div className="grid grid-cols-2 gap-0 mb-2">
        <p>
          <span className="font-bold w-24 inline-block">Name</span> :-&nbsp;
          {studentDetails.name || "____"}
        </p>
        <p>
          <span className="font-bold w-24 inline-block">Reg. No</span> :-&nbsp;
          {studentDetails.regNo || "____"}
        </p>
        <p>
          <span className="font-bold w-24 inline-block">Index No</span> :-&nbsp;
          {studentDetails.indexNo || "____"}
        </p>
      </div>

      <p className=" mb-2">
        Candidates are expected to produce this admission card to the
        Supervisor/Invigilator/Examiner at the Examination Hall. This form
        should be filled and signed by the candidates in the presence of the
        Supervisor/Invigilator/Examiner every time a paper test is taken. The
        Supervisor/Invigilator/Examiner is expected to authenticate the
        signature of the candidate by placing his/her initials in the
        appropriate column. Students are requested to hand over the admission
        card to the Supervisor on the last day of the paper.
      </p>

      <table className="w-full border-collapse border border-black text-sm mb-2">
        <thead>
          <tr>
            <th className="border border-black px-2 py-1">S.No</th>
            <th className="border border-black px-2 py-1">Unit Code</th>
            <th className="border border-black px-2 py-1">Subject</th>
            <th className="border border-black px-2 py-1">Eligibility</th>
            <th className="border border-black px-2 py-1">Date</th>
            <th className="border border-black px-2 py-1">
              Candidate’s Signature
            </th>
            <th className="border border-black px-2 py-1">
              Initials of Supervisor
            </th>
          </tr>
        </thead>
        <tbody>
          {/* {Object.keys(subjects).length
            ? subjects.map((subject, index) => (
                <tr key={index}>
                  <td className="border border-black px-2 py-1 text-center">
                    {index + 1}
                  </td>
                  <td className="border border-black px-2 py-1">
                    {subject.sub_id}
                  </td>
                  <td className="border border-black px-2 py-1">
                    {subject.subject}
                  </td>
                  <td className="border border-black px-2 py-1 text-center">
                    {subject.eligibility}
                  </td>
                  <td className="border border-black px-2 py-1 text-center">
                    {subject.date || "____"}
                  </td>
                  <td className="border border-black px-2 py-1">&nbsp;</td>
                  <td className="border border-black px-2 py-1">&nbsp;</td>
                </tr>
              ))
            :*/}
          {formData.subjects.map((arr, index) =>
            arr.map((sub_id, ind) => (
              <tr key={index + ":" + ind}>
                <td className="border border-black px-2 py-1 text-center">
                  {ind ? "" : index + 1}
                </td>
                <td className="border border-black px-2 py-1">
                  {subjectObject[sub_id]?.sub_code}
                </td>
                <td className="border border-black px-2 py-1 relative">
                  {subjectObject[sub_id]?.sub_name}
                  {formData.subjects.length - 1 == index &&
                  formData.subjects[index].length - 1 == ind ? (
                    <Button
                      variant="outline"
                      className="absolute right-2 top-1/2 -translate-y-1/2 text-red-500 text-xs rounded-full size-6 p-0"
                      size="sm"
                      onClick={() =>
                        setFormData((cur) => {
                          const updatedSubjects = [...cur.subjects]; // Create a shallow copy of the outer array
                          if (updatedSubjects.length > 0) {
                            const lastSubjectArray = [
                              ...updatedSubjects[updatedSubjects.length - 1],
                            ]; // Create a shallow copy of the last nested array
                            if (lastSubjectArray.length > 1) {
                              lastSubjectArray.pop(); // Remove the last element of the copied nested array
                              updatedSubjects[updatedSubjects.length - 1] =
                                lastSubjectArray; // Replace the original nested array with the updated one
                            } else {
                              updatedSubjects.pop(); // Remove the last array if it has only one element
                            }
                          }
                          return { ...cur, subjects: updatedSubjects }; // Return a new state object
                        })
                      }
                    >
                      <FaTimes />
                    </Button>
                  ) : (
                    ""
                  )}
                </td>
                <td className="border border-black px-2 py-1 text-center"></td>
                <td className="border border-black px-2 py-1 text-center"></td>
                <td className="border border-black px-2 py-1">&nbsp;</td>
                <td className="border border-black px-2 py-1">&nbsp;</td>
              </tr>
            ))
          )}
          {formData.subjects.flat().length &&
          formData.subjects.flat().length != batchCurriculumData?.length ? (
            <tr>
              <td></td>
              <td></td>
              <td className="px-2 py-1">
                <Select
                  onValueChange={(sub_id) =>
                    setFormData((cur) => {
                      const updatedSubjects = [...cur.subjects]; // Create a shallow copy of the outer array
                      if (updatedSubjects.length > 0) {
                        const lastSubjectArray = [
                          ...updatedSubjects[updatedSubjects.length - 1],
                        ]; // Create a shallow copy of the last nested array
                        lastSubjectArray.push(sub_id); // Modify the copied nested array
                        updatedSubjects[updatedSubjects.length - 1] =
                          lastSubjectArray; // Replace the original nested array with the updated one
                      }
                      return { ...cur, subjects: updatedSubjects }; // Return a new state object
                    })
                  }
                  value="0"
                >
                  <SelectTrigger className="w-40 h-8">
                    <SelectValue placeholder="+ Combined Unit" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectGroup>
                      <SelectLabel>Combined Unit</SelectLabel>
                      <SelectItem className="hidden" value="0">
                        + Combined Unit
                      </SelectItem>
                      {batchCurriculumData?.map((obj) => {
                        if (!formData.subjects.flat().includes(obj.sub_id)) {
                          return (
                            <SelectItem key={obj.sub_id} value={obj.sub_id}>
                              {obj.sub_code + " " + obj.sub_name}
                            </SelectItem>
                          );
                        }
                      })}
                    </SelectGroup>
                  </SelectContent>
                </Select>
              </td>
              <td></td>
              <td></td>
              <td>&nbsp;</td>
              <td>&nbsp;</td>
            </tr>
          ) : (
            ""
          )}
        </tbody>
      </table>
      {formData.subjects.flat().length != batchCurriculumData?.length ? (
        <Select
          onValueChange={(sub_id) =>
            setFormData((cur) => ({
              ...cur,
              subjects: [...cur.subjects, [sub_id]],
            }))
          }
          value="0"
        >
          <SelectTrigger className="w-32 h-8">
            <SelectValue placeholder="+ Unit" />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectLabel>Unit</SelectLabel>
              <SelectItem className="hidden" value="0">
                + Unit
              </SelectItem>
              {batchCurriculumData?.map((obj) => {
                if (!formData.subjects.flat().includes(obj.sub_id)) {
                  return (
                    <SelectItem key={obj.sub_id} value={obj.sub_id}>
                      {obj.sub_code + " " + obj.sub_name}
                    </SelectItem>
                  );
                }
              })}
            </SelectGroup>
          </SelectContent>
        </Select>
      ) : (
        ""
      )}

      {/* Footer Instructions */}
      <div className="text-sm mb-8 mt-2">
        <p className="font-bold underline">Instructions</p>
        <p>
          01. No candidate shall be admitted to the Examination hall without
          this card.
        </p>
        <p>
          02. If any candidate loses this admission card, he/she shall obtain a
          duplicate Admission Card on payment of Rs.150/-
        </p>
        <p>
          03. Every candidate shall produce his/her Identity Card at every
          paper/Practical Examination he/she sits for.
        </p>
        <p>
          04. Any unauthorized documents, notes & bags should not be taken into
          the Examinations.
        </p>
        <p>
          05. When unable to be present for any part of the Examination, it
          should be notified to me{" "}
          <span className="font-bold underline">immediately in writing</span> .
          No appeals will be considered later without this timely notification.
        </p>
      </div>

      {/* Footer */}
      <div className="flex justify-end">
        <div className="text-left">
          <p className="text-sm">Senior Asst. Registrar</p>
          <p className="text-sm">Examination & Student Admission</p>
          <p className="text-sm">{issueDate || getCurrentDate()}</p>
        </div>
      </div>
    </div>
  );
};

export default AdmissionCardTemplate;
