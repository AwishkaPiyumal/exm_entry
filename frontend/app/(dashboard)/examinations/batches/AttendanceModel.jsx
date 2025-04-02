"use client";

import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";
import { GiCancel } from "react-icons/gi";
import Dropzone from "@/components/Dropzone";
import { uploadAttendanceSheet } from "@/utils/apiRequests/batch.api";

const AttendanceModel = ({
  isAttendanceOpen,
  setIsAttendanceOpen,
  attendanceModalRef,
  attendanceId,
  setAttendanceId,
}) => {
  const [file, setFile] = useState(null);
  const [isLoading, setIsLoading] = useState(false);

  const onFormSubmitted = async () => {
    setIsLoading(true);
    const formData = new FormData();
    formData.append("file", file);
    formData.append("batch_id", attendanceId);

    try {
      const result = await uploadAttendanceSheet(formData);

      if (result.isFile) {
        toast.success("Failed records file downloaded.");
      } else {
        toast.success(result.message);
      }
    } catch (error) {
      toast.error("Operation failed. Please try again.");
      console.error("Error:", error);
    } finally {
      setFile(null);
      setIsLoading(false);
      setIsAttendanceOpen(false);
      setAttendanceId("");
    }
  };

  return (
    <>
      {isAttendanceOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div
            ref={attendanceModalRef}
            className="bg-white rounded-lg shadow-lg w-[425px] p-6"
          >
            <div className="flex justify-between items-center border-b pb-2 mb-4">
              <h3 className="text-lg font-semibold">Attendance Sheet</h3>
              <GiCancel
                className="text-2xl hover:cursor-pointer hover:text-zinc-700"
                onClick={() => {
                  setIsAttendanceOpen(false);
                  setFile(null);
                  setAttendanceId("");
                }}
              />
            </div>

            <div className="font-bahnschriftCon pl-5 mt-3">
              <h2 className="font-semibold">Instructions</h2>
              <ul className="list-disc text-sm">
                <li>Ensure the file is in CSV format.</li>
                <li>
                  The first row must be a header row (User name and subjects
                  codes ex:IT&nbsp;3143(P)).
                </li>
                <li>
                  Each row after the header must represent a single student
                </li>
                <li>
                  The 1st column is user name and remainings are attendance
                  percentage (without '%').
                </li>
              </ul>
            </div>
            <div className="grid gap-4 py-4">
              <Dropzone file={file} setFile={setFile} />
            </div>
            <div className="flex justify-end space-x-2 mt-4">
              <Button
                type="button"
                disabled={!file || !attendanceId || isLoading}
                onClick={onFormSubmitted}
              >
                {isLoading ? "Importing..." : "Import"}
              </Button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default AttendanceModel;
