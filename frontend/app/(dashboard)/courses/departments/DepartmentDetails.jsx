"use client";

import { Input } from "@/components/ui/input";
import { useEffect, useRef, useState } from "react";
import { MdCancel } from "react-icons/md";
import {
  Select,
  SelectContent,
  SelectGroup,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import Modal from "./Model";
import {
  getAllDepartmentsWithExtraDetails,
  updateDepartmentStatus,
} from "@/utils/apiRequests/course.api";
import { DataTable } from "@/components/DataTable";
import { Button } from "@/components/ui/button";
import { ArrowUpDown } from "lucide-react";
import { FaPen } from "react-icons/fa6";
import { Switch } from "@/components/ui/switch";
import { toast } from "sonner";
const DepartmentDetails = () => {
  const [filteredData, setFilteredData] = useState([]);
  const [searchValue, setSearchValue] = useState("");
  const [status, setStatus] = useState("all");
  const [isOpen, setIsOpen] = useState(false);
  const modalRef = useRef(null);
  const [editId, setEditId] = useState("");
  const queryClient = useQueryClient();

  const { data, isLoading, error } = useQuery({
    queryFn: getAllDepartmentsWithExtraDetails,
    queryKey: ["departmentsExtra"],
  });

  const { mutate } = useMutation({
    mutationFn: updateDepartmentStatus,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["departmentsExtra"]);
      setEditId("");
      toast.success(res.message);
    },
    onError: (err) => {
      setEditId("");
      toast.error("Operation failed");
    },
  });
  const onStatusChanged = async (e) => {
    let id = e.split(":")[0];
    let status = e.split(":")[1];
    mutate({ id, status });
  };

  const columns = [
    {
      accessorKey: "d_name",
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
      accessorKey: "faculty_name",
      header: "Faculty",
    },
    {
      accessorKey: "degree_count",
      header: "No of Degree programmes",
    },
    {
      id: "email",
      header: "Email",
      cell: ({ row }) => {
        return <p className="lowercase">{row.original.email}</p>;
      },
    },
    {
      accessorKey: "contact_no",
      header: "Contact No",
    },
    {
      accessorKey: "status",
      header: "Status",
      cell: ({ row }) => {
        return (
          <Switch
            id={row.original.d_id}
            onCheckedChange={(e) =>
              onStatusChanged(row.original.d_id + ":" + e)
            }
            checked={row.original.status == "true"}
          />
        );
      },
    },
    {
      id: "actions",
      header: "Actions",

      cell: ({ row }) => {
        return (
          <Button variant="outline" className="editBtn" id={row.original.d_id}>
            <FaPen />
            &nbsp;Edit
          </Button>
        );
      },
    },
  ];

  const onClearClicked = () => setSearchValue("");

  const onSearchChange = (e) => {
    setSearchValue(e.target.value);
  };

  const onStatusOptionClicked = (e) => {
    setStatus(e);
  };

  const toggleModal = () => {
    isOpen && setEditId("");
    setIsOpen((prev) => !prev);
  };

  const onEditClicked = (e) => {
    if (e.target.classList.contains("editBtn")) {
      setEditId(e.target.id);
      toggleModal();
    }
  };

  useEffect(() => {
    if (data) {
      let filtData1 = searchValue
        ? data.filter((item) =>
            item.d_name.toLowerCase().includes(searchValue.toLowerCase())
          )
        : data;
      let filtData2 = filtData1.filter((item) => {
        return status == "all" ? true : item.status == status;
      });
      setFilteredData(filtData2);
    }
  }, [searchValue, status, data]);

  return (
    <>
      <div className="flex justify-between mb-2 items-start">
        <div className="bg-white rounded-md flex relative">
          <Input
            placeholder="Search by name"
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
        <div className="flex items-center gap-5">
          <div className="flex gap-1 items-center">
            <p className="text-sm font-semibold">Status &nbsp;</p>
            <Select
              onValueChange={(e) => onStatusOptionClicked(e)}
              defaultValue="all"
            >
              <SelectTrigger className="w-[180px]">
                <SelectValue placeholder="Select a status" defaultValue="all" />
              </SelectTrigger>
              <SelectContent>
                <SelectGroup>
                  <SelectItem value="true">Active</SelectItem>
                  <SelectItem value="false">Not active</SelectItem>
                  <SelectItem value="all">All</SelectItem>
                </SelectGroup>
              </SelectContent>
            </Select>
          </div>
        </div>
      </div>
      <Modal
        editId={editId}
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        modalRef={modalRef}
        setEditId={setEditId}
      />
      <div className="container mx-auto">
        <DataTable
          columns={columns}
          data={filteredData}
          onEditClicked={onEditClicked}
          toggleModal={toggleModal}
          btnText="Create department"
        />
      </div>
    </>
  );
};

export default DepartmentDetails;
