"use client";

import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { GiCancel } from "react-icons/gi";

import {
  getAllFaculties,
  getDegreeById,
  getDegreesByDepartmentId,
  getDepartmentsByFacultyId,
} from "@/utils/apiRequests/course.api";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  createCurriculum,
  getCurriculumByDegLevSem,
  getCurriculumById,
  updateCurriculum,
} from "@/utils/apiRequests/curriculum.api";
import {
  Accordion,
  AccordionContent,
  AccordionItem,
  AccordionTrigger,
} from "@/components/ui/accordion";

import StudentSelection from "./StudentSelection";
import { getAllActiveManagers } from "@/utils/apiRequests/user.api";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Check, ChevronsUpDown } from "lucide-react";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import { cn } from "@/lib/utils";
import { FaExclamation } from "react-icons/fa";
import {
  createBatch,
  getBatchById,
  getBatchTimePeriod,
  setBatchTimePeriod,
  updateBatch,
} from "@/utils/apiRequests/batch.api";
import { convertDateFormat, convertUTCToLocal } from "@/utils/functions";

const DeadlineModel = ({
  deadlineId,
  isDeadlineOpen,
  setIsDeadlineOpen,
  deadlineModalRef,
  setDeadlineId,
}) => {
  const [formData, setFormData] = useState({});
  const [btnEnable, setBtnEnable] = useState(false);
  const queryClient = useQueryClient();

  const { status, mutate } = useMutation({
    mutationFn: setBatchTimePeriod,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["batches", deadlineId]);
      toast(res.message);
      setDeadlineId("");
    },
    onError: (err) => {
      console.log(err);
      setDeadlineId("");
      toast("Operation failed");
    },
  });

  const { data, refetch } = useQuery({
    queryFn: () => getBatchTimePeriod(deadlineId),
    queryKey: ["batches", deadlineId],
    enabled: false,
  });

  useEffect(() => {
    console.log(data);
    if (data && data.length) {
      let students_end = convertUTCToLocal(
        data?.filter((obj) => obj.user_type == "5")[0].end_date
      );
      let lecturers_end = convertUTCToLocal(
        data?.filter((obj) => obj.user_type == "4")[0].end_date
      );

      console.log(students_end, lecturers_end);

      setFormData({
        students_end,
        lecturers_end,
      });
    }
  }, [data]);

  const onFormDataChanged = (e) => {
    setFormData((curData) => ({
      ...curData,
      [e.target.name]: e.target.value,
    }));
  };

  const onAcadYearChanged = (e) => {
    let value = +e.target.value;
    if (value < +e.target.min) {
      value = +e.target.min;
    } else if (value > +e.target.max) {
      value = +e.target.max;
    }

    setFormData((curData) => ({
      ...curData,
      academic_year: value,
      batch_code: `${value}${specificDegreeData?.short || "XX"}${
        e.target?.name == "level" ? e.target?.value : formData.level || "X"
      }${
        e.target?.name == "sem_no" ? e.target?.value : formData.sem_no || "X"
      }`,
    }));
    e.target.value = value;
  };

  const onFormSubmitted = () => {
    const { students_end, lecturers_end } = formData;
    console.log(students_end, lecturers_end);
    mutate({
      batch_id: deadlineId,
      students_end,
      lecturers_end,
    });

    setIsDeadlineOpen(false);
  };

  const onFormReset = () => {
    setFormData(data || {});
  };

  useEffect(() => {
    let isFormValid = formData.students_end && formData.lecturers_end;

    setBtnEnable(isFormValid);
  }, [formData]);

  useEffect(() => {
    deadlineId && refetch();
  }, [deadlineId]);

  return (
    <>
      {isDeadlineOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div
            ref={deadlineModalRef}
            className={`sm:max-w-[425px] w-[425px] transition-all duration-300 bg-white rounded-lg shadow-lg p-6 `}
          >
            <div className="flex justify-between items-center border-b pb-2 mb-4">
              <h3 className="text-lg font-semibold">Deadlines</h3>

              <GiCancel
                className="text-2xl hover:cursor-pointer hover:text-zinc-700"
                onClick={() => {
                  setIsDeadlineOpen(false);
                  setFormData({});
                  setDeadlineId("");
                }}
              />
            </div>
            <div className="w-full flex flex-col justify-between ">
              <div
                className={`flex flex-col justify-start gap-4 sm:max-w-[380px] w-[380px] shrink-0 `}
              >
                <div className="grid grid-cols-4 items-center gap-4">
                  <Label htmlFor="students_end" className="text-right">
                    Students deadline
                  </Label>
                  <input
                    type="datetime-local"
                    id="students_end"
                    name="students_end"
                    className="col-span-3"
                    onChange={(e) => onFormDataChanged(e)}
                    value={formData.students_end || ""}
                  />
                </div>
                <div className="grid grid-cols-4 items-center gap-4">
                  <Label htmlFor="lecturers_end" className="text-right">
                    Lecturers deadline
                  </Label>
                  <input
                    type="datetime-local"
                    id="lecturers_end"
                    name="lecturers_end"
                    className="col-span-3"
                    onChange={(e) => onFormDataChanged(e)}
                    value={formData.lecturers_end || ""}
                  />
                </div>
              </div>

              <div className="flex justify-between space-x-2 mt-8">
                <Button
                  type="button"
                  variant="warning"
                  onClick={() => onFormReset()}
                >
                  Reset
                </Button>
                <Button
                  type="button"
                  disabled={!btnEnable}
                  onClick={onFormSubmitted}
                >
                  Set
                </Button>
              </div>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default DeadlineModel;
