"use client";
import dynamic from "next/dynamic";

const RichTextEditor = dynamic(() => import("./RichTextEditor"), {
  ssr: false,
});

import React, { useEffect, useRef, useState } from "react";
import UoV_Logo from "./../images/UoV_Logo.png";
import Image from "next/image";
import { useQuery } from "@tanstack/react-query";
import {
  getModifiedDate,
  numberToOrdinalWord,
  parseString,
} from "@/utils/functions";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectLabel,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { Calendar } from "@/components/ui/calendar";
import { cn } from "@/lib/utils";
import { CiCalendar as CalendarIcon } from "react-icons/ci";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { FaTimes } from "react-icons/fa";
import { FaPlus } from "react-icons/fa6";
import { Button } from "./ui/button";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";

const AdmissionCardTemplate = ({
  batch_id,
  setFormData,
  formData,
  batchFullDetailsData,
  latestAdmissionTemplateData,
  batchCurriculumData,
  level_ordinal,
  sem_ordinal,
  academicYear,
  subjectObject,
}) => {
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
    if (latestAdmissionTemplateData) {
      let obj = {};
      if (latestAdmissionTemplateData.exist) {
        obj.generated_date = latestAdmissionTemplateData?.data?.generated_date;
        obj.description = latestAdmissionTemplateData?.data?.description;
        obj.instructions = latestAdmissionTemplateData?.data?.instructions;
        obj.provider = latestAdmissionTemplateData?.data?.provider;

        const transformedSubjects =
          latestAdmissionTemplateData?.data?.subject_list
            ?.split(",")
            .map((comSubs) => comSubs.split(":"));
        const transformedDate = latestAdmissionTemplateData?.data?.exam_date
          ?.split(",")
          .map((item) => {
            const [year, months] = item.split(":");
            return {
              year: parseInt(year),
              months: months.split(";").map((mon) => +mon),
            };
          });

        obj.subjects = transformedSubjects;
        obj.date = transformedDate;
      } else {
        obj.description = latestAdmissionTemplateData?.data?.description;
        obj.instructions = latestAdmissionTemplateData?.data?.instructions;
        obj.provider = latestAdmissionTemplateData?.data?.provider;
      }

      setFormData((cur) => ({
        ...cur,
        ...obj,
      }));
    }
  }, [latestAdmissionTemplateData]);

  return (
    <div className="border-2 border-black p-8 max-w-4xl mx-auto font-times bg-white">
      <div className="text-center mb-4 ">
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

        <div className="flex justify-center font-semibold text-base uppercase space-x-2 items-center flex-wrap  leading-[1]">
          {level_ordinal} examination in {batchFullDetailsData?.deg_name} -{" "}
          {academicYear} - {sem_ordinal}
          &nbsp;semester -
          {formData.date?.map((yearBlock, yearIndex) => (
            <React.Fragment key={yearIndex}>
              <span>
                {formData.date?.length > 1 && (yearIndex || "") && ","}
              </span>
              <div key={yearIndex} className="flex space-x-3">
                <div className="flex items-center space-x-2">
                  {yearBlock.months?.map((month, monthIndex) => (
                    <div
                      key={monthIndex}
                      className="flex items-center space-x-1"
                    >
                      {yearBlock.months?.length > 1 && (monthIndex || "") && (
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
        <h3 className="text-xl uppercase font-bold leading-[1.1]">
          Admission Card
        </h3>
      </div>

      <div className="flex justify-between mb-2 text-sm">
        <p>
          <span className="font-bold inline-block">Name</span> :&nbsp; ____
        </p>
        <p>
          <span className="font-bold inline-block">Reg. No</span> :&nbsp; ____
        </p>
        <p>
          <span className="font-bold inline-block">Index No</span> :&nbsp; ____
        </p>
        <p>
          <span className="font-bold inline-block">Category</span> :&nbsp; ____
        </p>
      </div>

      <RichTextEditor
        setFormData={setFormData}
        text={formData.description}
        element="description"
        height="110px"
        width="100%"
      />

      <table className="w-full border-collapse border border-black text-sm mb-2">
        <thead>
          <tr>
            <th className="border border-black px-2 py-1">No.</th>
            <th className="border border-black px-2 py-1">Subject Code</th>
            <th className="border border-black px-2 py-1">Subject</th>
            <th className="border border-black px-2 py-1">Eligible</th>
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
          {formData.subjects?.map((arr, index) =>
            arr.map((sub_id, ind) => (
              <tr key={index + ":" + ind}>
                <td className="border border-black px-2 py-1 text-center leading-[0.9]">
                  {ind ? "" : index + 1}
                </td>
                <td className="border border-black px-2 py-1 leading-[0.9]">
                  {subjectObject[sub_id]?.sub_code}
                </td>
                <td className="border border-black px-2 py-1 relative leading-[0.9]">
                  {subjectObject[sub_id]?.sub_name}
                  {formData.subjects?.length - 1 == index &&
                  formData.subjects?.[index].length - 1 == ind ? (
                    <Button
                      variant="outline"
                      className="absolute right-2 top-1/2 -translate-y-1/2 text-red-500 text-xs rounded-full size-6 p-0"
                      size="sm"
                      onClick={() =>
                        setFormData((cur) => {
                          const updatedSubjects = [...cur.subjects];
                          if (updatedSubjects.length > 0) {
                            const lastSubjectArray = [
                              ...updatedSubjects[updatedSubjects.length - 1],
                            ];
                            if (lastSubjectArray.length > 1) {
                              lastSubjectArray.pop();
                              updatedSubjects[updatedSubjects.length - 1] =
                                lastSubjectArray;
                            } else {
                              updatedSubjects.pop();
                            }
                          }
                          return { ...cur, subjects: updatedSubjects };
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
          {formData.subjects?.flat().length &&
          formData.subjects?.flat().length != batchCurriculumData?.length ? (
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
                  <SelectTrigger className="w-40 h-8 border border-black">
                    <SelectValue placeholder="+ Combined Unit" />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectGroup>
                      <SelectLabel>Combined Units</SelectLabel>
                      <SelectItem className="hidden" value="0">
                        + Combined Unit
                      </SelectItem>
                      {batchCurriculumData?.map((obj) => {
                        if (
                          !formData.subjects
                            .flat()
                            .map((item) => +item)
                            .includes(+obj.sub_id)
                        ) {
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
      {formData.subjects?.flat().length != batchCurriculumData?.length ? (
        <Select
          onValueChange={(sub_id) =>
            setFormData((cur) => ({
              ...cur,
              subjects: [...cur.subjects, [sub_id]],
            }))
          }
          value="0"
        >
          <SelectTrigger className="w-32 h-8 border border-black">
            <SelectValue placeholder="+ Unit" />
          </SelectTrigger>
          <SelectContent>
            <SelectGroup>
              <SelectLabel>Units</SelectLabel>
              <SelectItem className="hidden" value="0">
                + Unit
              </SelectItem>
              {batchCurriculumData?.map((obj) => {
                if (
                  !formData.subjects
                    .flat()
                    .map((item) => +item)
                    .includes(+obj.sub_id)
                ) {
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
        <RichTextEditor
          setFormData={setFormData}
          text={formData.instructions}
          element="instructions"
          height="160px"
          width="100%"
        />
      </div>

      {/* Footer */}
      <div className="flex justify-end">
        <div className="text-left">
          <RichTextEditor
            setFormData={setFormData}
            text={formData.provider}
            element="provider"
            height="100px"
            width="380px"
          />

          <Popover>
            <PopoverTrigger asChild>
              <Button
                variant={"outline"}
                className={cn(
                  "w-[200px] justify-between text-left font-normal",
                  !formData.generated_date && "text-muted-foreground"
                )}
              >
                {formData.generated_date || <span>Pick a date</span>}{" "}
                <CalendarIcon className="mr-2 h-4 w-4" />
              </Button>
            </PopoverTrigger>
            <PopoverContent className="w-auto p-0">
              <Calendar
                mode="single"
                selected={formData.generated_date}
                onSelect={(e) =>
                  setFormData((cur) => ({
                    ...cur,
                    generated_date: getModifiedDate(e),
                  }))
                }
                initialFocus
              />
            </PopoverContent>
          </Popover>
        </div>
      </div>
    </div>
  );
};

export default AdmissionCardTemplate;
