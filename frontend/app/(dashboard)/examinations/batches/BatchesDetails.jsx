"use client";
import { DataTable } from "./DataTable";
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
  getAllBatchDetails,
  getAllBatches,
  updateBatchStatus,
} from "@/utils/apiRequests/batch.api";
import StudentModel from "./StudentModel";
import DeadlineModel from "./DeadlineModel";
import { Button } from "@/components/ui/button";
import { ArrowUpDown } from "lucide-react";
import { FaClock, FaPen, FaUserPlus } from "react-icons/fa6";
import {
  Tooltip,
  TooltipContent,
  TooltipProvider,
  TooltipTrigger,
} from "@/components/ui/tooltip";
import { Switch } from "@/components/ui/switch";
import { toast, Toaster } from "sonner";

const BatchesDetails = () => {
  const [filteredData, setFilteredData] = useState([]);
  const [searchValue, setSearchValue] = useState("");
  const [status, setStatus] = useState("all");
  const [isOpen, setIsOpen] = useState(false);
  const [isFeedOpen, setIsFeedOpen] = useState(false);
  const [isDeadlineOpen, setIsDeadlineOpen] = useState(false);
  const modalRef = useRef(null);
  const studentModalRef = useRef(null);
  const deadlineModalRef = useRef(null);
  const [editId, setEditId] = useState("");
  const [feedId, setFeedId] = useState("");
  const [deadlineId, setDeadlineId] = useState("");
  const [feedDegShort, setFeedDegShort] = useState("");
  const queryClient = useQueryClient();

  const { data, isLoading, error } = useQuery({
    queryFn: getAllBatchDetails,
    queryKey: ["batches"],
  });

  const { mutate } = useMutation({
    mutationFn: updateBatchStatus,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["batches"]);
      setEditId("");
      toast(res.message);
    },
    onError: (err) => {
      console.log(err);
      setEditId("");
      toast("Operation failed");
    },
  });

  const onStatusChanged = async (e) => {
    let id = e.split(":")[0];
    let status = e.split(":")[1];
    mutate({ id, status });
  };
  const columns = [
    {
      accessorKey: "batch_code",
      header: "Batch code",
    },
    {
      id: "academic_year",

      header: ({ column }) => {
        return (
          <Button
            variant="ghost"
            onClick={() => column.toggleSorting(column.getIsSorted() === "asc")}
          >
            Academic year
            <ArrowUpDown className="ml-2 h-4 w-4" />
          </Button>
        );
      },
      cell: ({ row }) => {
        let academic_year = row.original.batch_code.slice(0, 4);
        return <p className="text-center">{academic_year}</p>;
      },
    },
    {
      accessorKey: "degree_name",
      header: "Degree programme",
    },
    {
      id: "level",

      header: "Level",
      cell: ({ row }) => {
        let level = row.original.batch_code.slice(
          row.original.batch_code.length - 2,
          row.original.batch_code.length - 1
        );
        return <p className="text-center">{level}</p>;
      },
    },
    {
      id: "sem",

      header: "Semester",
      cell: ({ row }) => {
        let sem = row.original.batch_code.slice(
          row.original.batch_code.length - 1
        );
        return <p className="text-center">{sem}</p>;
      },
    },
    {
      id: "Entries",
      header: "Entries",
      cell: ({ row }) => {
        return <p className="text-center">{row.original.student_count}</p>;
      },
    },
    {
      id: "status",
      header: "Status",
      cell: ({ row }) => {
        return (
          <Switch
            id={row.original.batch_id}
            onCheckedChange={(e) =>
              onStatusChanged(row.original.batch_id + ":" + e)
            }
            checked={row.original.batch_status == "true"}
          />
        );
      },
    },
    {
      id: "actions",
      header: () => {
        return <p className="text-center">Actions</p>;
      },

      cell: ({ row }) => {
        let short = row.original.batch_code.slice(
          4,
          row.original.batch_code.length - 2
        );
        return (
          <div className="flex gap-2">
            {row.original.student_count ? (
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger>
                    <span className="inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 border border-input bg-background shadow-sm hover:bg-accent hover:text-accent-foreground h-9 px-4 py-2 cursor-not-allowed">
                      <FaPen />
                      &nbsp;Edit
                    </span>
                  </TooltipTrigger>
                  <TooltipContent className="bg-white text-black shadow-lg p-2">
                    <p>
                      student(s) already applied for the exam. so you can't edit
                      now
                    </p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>
            ) : (
              <Button
                variant="outline"
                className="editBtn"
                id={row.original.batch_id}
              >
                <FaPen />
                &nbsp;Edit
              </Button>
            )}
            <Button
              variant="outline"
              className="deadlineBtn"
              id={row.original.batch_id}
            >
              <FaClock />
              &nbsp;Set Deadlines
            </Button>
            {row.original.student_count ? (
              <TooltipProvider>
                <Tooltip>
                  <TooltipTrigger>
                    <span className="inline-flex items-center justify-center gap-2 whitespace-nowrap rounded-md text-sm font-medium transition-colors focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:pointer-events-none opacity-50 [&_svg]:pointer-events-none [&_svg]:size-4 [&_svg]:shrink-0 bg-primary text-primary-foreground shadow hover:bg-primary/90 h-9 px-4 py-2 cursor-not-allowed">
                      <FaUserPlus />
                      &nbsp;Feed students
                    </span>
                  </TooltipTrigger>
                  <TooltipContent className="bg-white text-black shadow-lg p-2">
                    <p>
                      student(s) already applied for the exam. so you can't
                      add/remove students now
                    </p>
                  </TooltipContent>
                </Tooltip>
              </TooltipProvider>
            ) : (
              <Button
                className="feedBtn"
                id={row.original.batch_id + ":" + short}
              >
                <FaUserPlus />
                &nbsp;Feed students
              </Button>
            )}
          </div>
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

  const toggleDeadlineModal = () => {
    isDeadlineOpen && setDeadlineId("");
    setIsDeadlineOpen((prev) => !prev);
  };

  const toggleModal = () => {
    isOpen && setEditId("");
    setIsOpen((prev) => !prev);
  };

  const toggleFeedModal = () => {
    isFeedOpen && setFeedId("") && setFeedDegShort("");
    setIsFeedOpen((prev) => !prev);
  };

  const onBtnClicked = (e) => {
    if (e.target.classList.contains("editBtn")) {
      setEditId(e.target.id);
      toggleModal();
    }

    if (e.target.classList.contains("feedBtn")) {
      setFeedId(e.target.id.split(":")[0]);
      setFeedDegShort(e.target.id.split(":")[1]);
      toggleFeedModal();
    }

    if (e.target.classList.contains("deadlineBtn")) {
      setDeadlineId(e.target.id);
      toggleDeadlineModal();
    }
  };

  useEffect(() => {
    if (data) {
      console.log(data);
      let filtData1 = searchValue
        ? data.filter((item) =>
            item.batch_id.toLowerCase().includes(searchValue.toLowerCase())
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
      <DeadlineModel
        deadlineId={deadlineId}
        isDeadlineOpen={isDeadlineOpen}
        setIsDeadlineOpen={setIsDeadlineOpen}
        deadlineModalRef={deadlineModalRef}
        setDeadlineId={setDeadlineId}
      />
      <Modal
        editId={editId}
        isOpen={isOpen}
        setIsOpen={setIsOpen}
        modalRef={modalRef}
        setEditId={setEditId}
      />
      <StudentModel
        feedId={feedId}
        feedDegShort={feedDegShort}
        setIsFeedOpen={setIsFeedOpen}
        isFeedOpen={isFeedOpen}
        studentModalRef={studentModalRef}
        setFeedId={setFeedId}
        setFeedDegShort={setFeedDegShort}
      />
      <div className="container mx-auto">
        <DataTable
          columns={columns}
          data={filteredData}
          onBtnClicked={onBtnClicked}
          toggleModal={toggleModal}
        />
      </div>
    </>
  );
};

export default BatchesDetails;
