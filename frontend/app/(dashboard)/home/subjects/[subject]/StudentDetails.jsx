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
import { getDeadlinesForBatch } from "@/utils/apiRequests/batch.api";
import { useUser } from "@/utils/useUser";

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
      header: () => {
        const [remark, setRemark] = useState("");
        const triggerRef = useRef(null);

        const isAnyoneNotEligible = filteredData.some(
          (stu) => stu.eligibility == "false"
        );
        return (
          <div className="flex justify-between">
            <span>Eligibility</span>
            <Switch
              onClick={(e) => {
                e.preventDefault();
                triggerRef.current.click();
              }}
              checked={filteredData.length && !isAnyoneNotEligible}
              disabled={!filteredData.length}
            />
            <Popover>
              <PopoverTrigger
                ref={triggerRef}
                className="w-[0px]"
              ></PopoverTrigger>
              <PopoverContent className="w-64 h-40 flex flex-col gap-2 items-start">
                <p className="font-semibold flex justify-between text-sm w-full">
                  <span>Enter Remark</span>
                  <span>All/Filtered Students</span>
                </p>
                <Textarea
                  onChange={(e) => setRemark(e.target.value)}
                  onBlur={() => setRemark("")}
                  value={remark}
                />
                <Button
                  className="self-end changeEli"
                  onMouseDown={() => {
                    if (remark) {
                      onMultipleEligibilityChanged(
                        isAnyoneNotEligible + "",
                        remark
                      );
                    }
                  }}
                  disabled={!remark}
                >
                  Change Eligibility
                </Button>
              </PopoverContent>
            </Popover>
          </div>
        );
      },
      cell: ({ row }) => {
        const [remark, setRemark] = useState("");

        return (
          <Popover>
            <PopoverTrigger className="trigger flex justify-center w-full">
              <Switch
                id={row.original.s_id}
                onClick={(e) => {
                  e.preventDefault();
                  e.target.parentElement.click();
                }}
                checked={row.original.eligibility == "true"}
              />
            </PopoverTrigger>
            <PopoverContent className="w-64 h-40 flex flex-col gap-2 items-start">
              <p className="font-semibold flex justify-between text-sm w-full">
                <span>Enter Remark</span>
                <span>{row.original.user_name}</span>
              </p>
              <Textarea
                onChange={(e) => setRemark(e.target.value)}
                onBlur={() => setRemark("")}
                value={remark}
              />
              <Button
                className="self-end changeEli"
                onMouseDown={() => {
                  if (remark) {
                    const val = row.original.eligibility == "true";
                    onEligibilityChanged(row.original.s_id, !val + "", remark);
                  }
                }}
                disabled={!remark}
              >
                Change Eligibility
              </Button>
            </PopoverContent>
          </Popover>
        );
      },
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
      <div className="flex gap-2 px-5 mb-4">
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="text-green-900 font-serif">Student Submission</div>
          <div className="bg-gradient-to-r from-green-100 to-green-500 h-1 w-full"></div>
          <div className="bg-green-500 h-6 w-1 self-end"></div>
          <div className="absolute right-0 translate-x-1/2 bottom-0 text-green-700  font-semibold text-sm font-mono">
            {new Date(deadlineObj.stu_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.stu_deadline).toString().indexOf("GMT")
              )}
          </div>
        </div>
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="absolute right-0 translate-x-1/2 top-0 text-blue-700  font-semibold text-sm font-mono">
            {new Date(deadlineObj.lec_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.lec_deadline).toString().indexOf("GMT")
              )}{" "}
          </div>
          <div className="bg-blue-500 h-6 w-1 self-end"></div>
          <div className="bg-gradient-to-r from-blue-100 to-blue-500 h-1 w-full"></div>
          <div className="text-blue-900 font-serif">Lecturer Review</div>
        </div>
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="text-orange-900 font-serif">HOD Approval</div>
          <div className="bg-gradient-to-r from-orange-100 to-orange-500 h-1 w-full"></div>
          <div className="bg-orange-500 h-6 w-1 self-end"></div>
          <div className="absolute right-0 translate-x-1/2 bottom-0 text-orange-700  font-semibold text-sm font-mono">
            {new Date(deadlineObj.hod_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.hod_deadline).toString().indexOf("GMT")
              )}{" "}
          </div>
        </div>
        <div className="flex flex-col flex-1 shrink-0 relative py-7 items-center">
          <div className="absolute right-0 translate-x-1/2 top-0 text-red-700  font-semibold text-sm font-mono">
            {new Date(deadlineObj.dean_deadline)
              .toString()
              .slice(
                4,
                new Date(deadlineObj.dean_deadline).toString().indexOf("GMT")
              )}{" "}
          </div>
          <div className="bg-red-500 h-6 w-1 self-end"></div>
          <div className="bg-gradient-to-r from-red-100 to-red-500 h-1 w-full"></div>
          <div className="text-red-900 font-serif">Dean Approval</div>
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
            } text-sm font-medium text-slate-700 absolute top-2 right-2 transition-all duration-200`}
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
