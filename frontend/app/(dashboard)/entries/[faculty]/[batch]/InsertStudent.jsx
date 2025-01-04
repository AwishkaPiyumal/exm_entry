"use client";

import { Check, ChevronsDown, ChevronsUpDown } from "lucide-react";

import { cn } from "@/lib/utils";
import { Button } from "@/components/ui/button";
import {
  Command,
  CommandEmpty,
  CommandGroup,
  CommandInput,
  CommandItem,
  CommandList,
} from "@/components/ui/command";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { FaPlus } from "react-icons/fa6";
import { getNonBatchStudents } from "@/utils/apiRequests/batch.api";
import { useQuery } from "@tanstack/react-query";
import { useEffect, useState } from "react";
import { getStudentSubjects } from "@/utils/apiRequests/entry.api";

const InsertStudent = ({
  batch_id,
  setSelectedSubjects,
  selectedSubjects,
  setRows,
}) => {
  const [open, setOpen] = useState(false);
  const [sId, setSId] = useState("");
  const [userName, setUserName] = useState("");
  const [facultyStudents, setFacultyStudents] = useState([]);

  const { data: nonBatchStudentsData, isLoading: nonBatchStudentsDataLoading } =
    useQuery({
      queryFn: () => getNonBatchStudents(batch_id),
      queryKey: ["nonBatchStudents"],
    });

  const {
    data: studentSubjectsData,
    refetch: refetchStudentSubjectsData,
    isLoading: studentSubjectsDataLoading,
  } = useQuery({
    queryFn: () => getStudentSubjects(batch_id, sId),
    queryKey: ["studentSubjects", sId],
    enabled: false,
  });

  useEffect(() => {
    nonBatchStudentsData?.length &&
      setFacultyStudents(
        nonBatchStudentsData?.map((stu) => ({
          ...stu,
          s_id: stu.s_id + ":" + stu.user_name,
        }))
      );
  }, [nonBatchStudentsData]);

  useEffect(() => {
    console.log(sId);
    sId && refetchStudentSubjectsData();
  }, [sId]);

  useEffect(() => {
    console.log(studentSubjectsData);
    if (studentSubjectsData?.length) {
      sId &&
        setSelectedSubjects((cur) => ({
          ...cur,
          [sId]: {
            userName,
            existingSubjects: studentSubjectsData.map((obj) => obj.sub_id),
            newSubjects: cur[sId]?.newSubjects?.length
              ? cur[sId].newSubjects
              : [],
          },
        }));
    } else {
      sId &&
        setSelectedSubjects((cur) => ({
          ...cur,
          [sId]: {
            userName,
            existingSubjects: [],
            newSubjects: cur[sId]?.newSubjects?.length
              ? cur[sId].newSubjects
              : [],
          },
        }));
    }

    setSId("");
    setUserName("");
  }, [studentSubjectsData]);

  return (
    <Popover open={open} onOpenChange={setOpen}>
      <PopoverTrigger asChild>
        <Button
          role="combobox"
          aria-expanded={open}
          className="w-[200px] justify-between mt-5"
          disabled={nonBatchStudentsDataLoading || studentSubjectsDataLoading}
        >
          {nonBatchStudentsDataLoading || studentSubjectsDataLoading
            ? "Please wait"
            : "Insert row"}
          <FaPlus className="ml-2 h-4 w-4 shrink-0" />
        </Button>
      </PopoverTrigger>
      <PopoverContent className="w-[200px] p-0">
        <Command>
          <CommandInput placeholder="Search student..." />
          <CommandList>
            <CommandEmpty>No student found.</CommandEmpty>
            <CommandGroup>
              {facultyStudents.map((student) => (
                <CommandItem
                  key={student.s_id}
                  value={student.s_id}
                  onSelect={(currentValue) => {
                    setRows((cur) => [...cur, currentValue.split(":")[0]]);
                    setSId(currentValue.split(":")[0]);
                    setUserName(currentValue.split(":")[1]);
                    setOpen(false);
                  }}
                >
                  {student.user_name}
                </CommandItem>
              ))}
            </CommandGroup>
          </CommandList>
        </Command>
      </PopoverContent>
    </Popover>
  );
};

export default InsertStudent;
