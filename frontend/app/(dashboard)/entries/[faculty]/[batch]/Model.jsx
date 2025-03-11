"use client";

import { toast } from "sonner";
import { Input } from "@/components/ui/input";
import { Label } from "@/components/ui/label";
import { Button } from "@/components/ui/button";
import { Checkbox } from "@/components/ui/checkbox";
import { forwardRef, useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { GiCancel } from "react-icons/gi";

import {
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { cn } from "@/lib/utils";

import InsertStudent from "./InsertStudent";
import StudentRow from "./StudentRow";
import { addMedicalResitStudents } from "@/utils/apiRequests/entry.api";

const Table = forwardRef(({ className, ...props }, ref) => (
  <div className="relative w-full h-80 overflow-auto">
    <table
      ref={ref}
      className={cn("w-full caption-bottom text-sm", className)}
      {...props}
    />
  </div>
));
Table.displayName = "Table";

const transformData = (input) => {
  const result = {};

  Object.entries(input).forEach(([s_id, studentData]) => {
    studentData.newSubjects.forEach(({ sub_id, type }) => {
      if (!result[sub_id]) {
        result[sub_id] = [];
      }

      result[sub_id].push({ s_id: parseInt(s_id), type });
    });
  });

  return result;
};

const Model = ({
  isOpen,
  setIsOpen,
  modalRef,
  curriculumsOfBatchData,
  batch_id,
}) => {
  const queryClient = useQueryClient();
  const [selectedSubjects, setSelectedSubjects] = useState({});
  const [rows, setRows] = useState([]);

  const { status, mutate } = useMutation({
    mutationFn: addMedicalResitStudents,
    onSuccess: (res) => {
      toast.success(res.message);
    },
    onError: (err) => {
      toast.error("Operation failed");
    },
  });

  const onFormSubmitted = () => {
    let data = transformData(selectedSubjects);

    if (Object.keys(data).length) {
      mutate({ data, batch_id });
    } else {
      toast("Nothing to insert");
    }
    setIsOpen(false);
    setSelectedSubjects({});
    setRows([]);
  };

  return (
    <>
      {isOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div
            ref={modalRef}
            className="bg-white rounded-lg shadow-lg w-[80vw] p-6 h-[85vh]"
          >
            <div className="flex justify-between items-center border-b pb-2 mb-4">
              <h3 className="text-lg font-semibold">Medical / Resit</h3>

              <GiCancel
                className="text-2xl hover:cursor-pointer hover:text-zinc-700"
                onClick={() => {
                  setIsOpen(false);
                  setSelectedSubjects({});
                  setRows([]);
                }}
              />
            </div>

            <Table>
              <TableHeader>
                <TableRow className="flex bg-white">
                  <TableHead className="w-[150px]">Student</TableHead>
                  <TableHead className="w-8"></TableHead>
                  <TableHead className="w-24 text-center">Type</TableHead>
                  {curriculumsOfBatchData &&
                    curriculumsOfBatchData.map((obj) => (
                      <TableHead key={obj.sub_id} className="w-16">
                        {obj.sub_code}
                      </TableHead>
                    ))}
                </TableRow>
              </TableHeader>
              <TableBody>
                {rows.map(
                  (row, ind) =>
                    row && (
                      <StudentRow
                        row={row}
                        curriculumsOfBatchData={curriculumsOfBatchData}
                        selectedSubjects={selectedSubjects}
                        setSelectedSubjects={setSelectedSubjects}
                        ind={ind}
                        setRows={setRows}
                        key={ind}
                      />
                    )
                )}
              </TableBody>
            </Table>
            <InsertStudent
              batch_id={batch_id}
              setSelectedSubjects={setSelectedSubjects}
              selectedSubjects={selectedSubjects}
              setRows={setRows}
            />
            <div className="flex justify-end space-x-2 mt-4">
              <Button type="button" onClick={onFormSubmitted}>
                Insert
              </Button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Model;
