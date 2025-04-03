"use client";

import { Input } from "@/components/ui/input";
import { useEffect, useRef, useState } from "react";
import { MdCancel } from "react-icons/md";
import { Button } from "@/components/ui/button";
import { ArrowUpDown } from "lucide-react";
import { Switch } from "@/components/ui/switch";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { getAllStudents } from "@/utils/apiRequests/user.api";
import { EntriesDataTable } from "@/components/EntriesDataTable";
import {
  updateEligibility,
  updateMultipleEligibility,
} from "@/utils/apiRequests/curriculum.api";
import {
  Popover,
  PopoverContent,
  PopoverTrigger,
} from "@/components/ui/popover";
import { Textarea } from "@/components/ui/textarea";
import { toast } from "sonner";
import {
  getAppliedStudentsForSubject,
  getAppliedStudentsForSubjectOfDepartment,
  getAppliedStudentsForSubjectOfFaculty,
} from "@/utils/apiRequests/entry.api";
import {
  getBatchOpenDate,
  getDeadlinesForBatch,
} from "@/utils/apiRequests/batch.api";
import { useUser } from "@/utils/useUser";
import EligibilityHeader from "@/components/EligibilityHeader";
import EligibilityCell from "@/components/EligibilityCell";

const StudentDetails = ({ sub_id, batch_id }) => {
  const queryClient = useQueryClient();
  const [filteredData, setFilteredData] = useState([]);
  const [searchValue, setSearchValue] = useState("");
  const [deadlineObj, setDeadlineObj] = useState({
    lec_deadline: "",
    hod_deadline: "",
    dean_deadline: "",
    stu_deadline: "",
  });
  const [roleId, setRoleID] = useState(null);
  const { data: user, isLoading } = useUser();

  useEffect(() => {
    if (user?.role_id) {
      setRoleID(user?.role_id);
    }
  }, [user]);

  const { data: openDateData } = useQuery({
    queryFn: () => getBatchOpenDate(batch_id),
    queryKey: ["batch", "openDate", batch_id],
  });

  const { data, error } = useQuery({
    queryFn: () =>
      roleId == "4" ? getAppliedStudentsForSubject(batch_id, sub_id) : null,
    queryKey: ["students", "subject", sub_id],
    enabled: roleId == "4",
  });

  const { data: deadlineData } = useQuery({
    queryFn: () => getDeadlinesForBatch(batch_id),
    queryKey: ["batch", "dealines", batch_id],
  });

  if (error?.response?.status == 500) {
    window.location.href = "/home";
  }

  const { mutate } = useMutation({
    mutationFn: updateEligibility,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["students", "subject", sub_id]);
      toast.success(res.message);
    },
    onError: (err) => {
      toast.error("Operation failed");
    },
  });

  const { mutate: mutateMultiple } = useMutation({
    mutationFn: updateMultipleEligibility,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["students", "subject", sub_id]);
      toast.success(res.message);
    },
    onError: (err) => {
      toast.error("Operation failed");
    },
  });

  const onEligibilityChanged = async (s_id, eligibility, remark) => {
    mutate({ batch_id, sub_id, eligibility, s_id, remark });
  };

  const onMultipleEligibilityChanged = async (eligibility, remark) => {
    mutateMultiple({
      batch_id,
      sub_id,
      eligibility,
      s_ids: filteredData.map((stu) => stu.s_id),
      remark,
    });
  };

  const columns = [
    {
      accessorKey: "user_name",
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          >
            User name
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        );
      },
    },
    {
      accessorKey: "name",
      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          >
            Name
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        );
      },
    },
    {
      accessorKey: "attendance",
      header: "Attendance",
      cell: ({ row }) => {
        return (
          <p className="text-center ">
            {row.original.attendance
              ? +row.original.attendance
                ? row.original.attendance + "%"
                : row.original.attendance
              : "0%"}
          </p>
        );
      },
    },
    {
      id: "Eligibility",
      header: () => (
        <EligibilityHeader
          filteredData={filteredData}
          onMultipleEligibilityChanged={onMultipleEligibilityChanged}
        />
      ),

      cell: ({ row }) => (
        <EligibilityCell
          row={row}
          onEligibilityChanged={onEligibilityChanged}
        />
      ),
    },
  ];

  const onClearClicked = () => setSearchValue("");

  const onSearchChange = (e) => {
    setSearchValue(e.target.value);
  };

  useEffect(() => {
    if (data) {
      let filtData = searchValue
        ? data.filter(
            (item) =>
              item.name.toLowerCase().includes(searchValue.toLowerCase()) ||
              item.user_name.toLowerCase().includes(searchValue.toLowerCase())
          )
        : data;

      setFilteredData(filtData);
    }
  }, [searchValue, data]);

  useEffect(() => {
    if (deadlineData && deadlineData.length) {
      setDeadlineObj({
        stu_deadline: deadlineData.filter((obj) => obj.user_type == "5")[0]
          .deadline,
        lec_deadline: deadlineData.filter((obj) => obj.user_type == "4")[0]
          .deadline,
        hod_deadline: deadlineData.filter((obj) => obj.user_type == "3")[0]
          .deadline,
        dean_deadline: deadlineData.filter((obj) => obj.user_type == "2")[0]
          .deadline,
      });
    }
  }, [deadlineData]);

  return (
    <>
      <div className="flex px-1 mb-4 text-xs lg:text-sm">
        <div className="self-center text-wrap w-16 text-center text-slate-600">
          {new Date(openDateData?.application_open)
            .toString()
            .slice(
              4,
              new Date(openDateData?.application_open).toString().indexOf("GMT")
            )}
        </div>
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="bg-gradient-to-r from-green-100 to-blue-300 h-1 w-full mt-6 mb-1"></div>
          <div className="bg-gradient-to-r from-green-100 to-green-500 h-1 w-full"></div>
          <div className="flex justify-end self-stretch gap-3">
            <div className="text-green-900 font-serif ">Student Submission</div>
            <div className="bg-green-500 h-6 w-1"></div>
          </div>
          <div className="absolute right-0 translate-x-1/2 bottom-0 text-green-700  font-semibold  font-mono">
            {new Date(deadlineObj.stu_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.stu_deadline).toString().indexOf("GMT")
              )}
          </div>
        </div>
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="absolute right-0 translate-x-1/2 top-0 text-blue-700  font-semibold  font-mono">
            {new Date(deadlineObj.lec_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.lec_deadline).toString().indexOf("GMT")
              )}{" "}
          </div>
          <div className="flex justify-end self-stretch gap-3 items-end">
            <div className="text-blue-900 font-serif">Lecturer Review</div>
            <div className="bg-blue-500 h-6 w-1"></div>
          </div>

          <div className="bg-gradient-to-r from-blue-300 to-blue-500 h-1 w-full"></div>
        </div>
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="bg-gradient-to-r from-orange-100 to-orange-500 h-1 w-full mt-8"></div>
          <div className="flex justify-end self-stretch gap-3 ">
            <div className="text-orange-900 font-serif">HOD Approval</div>
            <div className="bg-orange-500 h-6 w-1"></div>
          </div>
          <div className="absolute right-0 translate-x-1/2 bottom-0 text-orange-700  font-semibold  font-mono">
            {new Date(deadlineObj.hod_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.hod_deadline).toString().indexOf("GMT")
              )}{" "}
          </div>
        </div>
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="absolute right-0 translate-x-1/4 top-0 text-red-700  font-semibold  font-mono">
            {new Date(deadlineObj.dean_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.dean_deadline).toString().indexOf("GMT")
              )}{" "}
          </div>
          <div className="flex justify-end self-stretch gap-3 items-end">
            <div className="text-orange-900 font-serif">Dean Approval</div>
            <div className="bg-red-500 h-6 w-1"></div>
          </div>

          <div className="bg-gradient-to-r from-red-100 to-red-500 h-1 w-full"></div>
        </div>
      </div>
      <div className="flex items-start mb-3">
        <div className="bg-white rounded-md flex relative">
          <Input
            placeholder="Search by name or user name"
            onChange={(e) => onSearchChange(e)}
            value={searchValue}
            className="md:w-60"
          />
          <span
            className={`${
              searchValue ? "opacity-100 inline-block" : "opacity-0 hidden"
            } font-medium text-slate-700 absolute top-2 right-2 transition-all duration-200`}
            onClick={onClearClicked}
          >
            <MdCancel className="size-5 cursor-pointer" />
          </span>
        </div>
      </div>
      <div className="container mx-auto">
        <EntriesDataTable columns={columns} data={filteredData} />
      </div>
    </>
  );
};

export default StudentDetails;
