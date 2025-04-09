"use client";

import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { multipleStudentsRegister } from "@/utils/apiRequests/auth.api";
import { GiCancel } from "react-icons/gi";
import Dropzone from "@/components/Dropzone";
import { Label } from "@/components/ui/label";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import { getAllFaculties } from "@/utils/apiRequests/course.api";

const ImportModel = ({ isImportOpen, setIsImportOpen, importModalRef }) => {
  const [file, setFile] = useState(null);
  const [f_id, setF_id] = useState(null);
  const [isLoading, setIsLoading] = useState(false);
  const queryClient = useQueryClient();

  const { data: facultyData } = useQuery({
    queryFn: getAllFaculties,
    queryKey: ["faculties"],
  });

  const onFormSubmitted = async () => {
    setIsLoading(true);
    const formData = new FormData();
    formData.append("file", file);
    formData.append("f_id", f_id);

    try {
      const result = await multipleStudentsRegister(formData);

      if (result.isFile) {
        toast.success("Failed records file downloaded.");
      } else {
        toast.success(result.message);
      }
    } catch (error) {
      toast.error("Operation failed. Please try again.");
      console.error("Error:", error);
    } finally {
      queryClient.invalidateQueries(["students"]);
      setFile(null);
      setF_id(null);
      setIsLoading(false);
      setIsImportOpen(false);
    }
  };

  return (
    <>
      {isImportOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div
            ref={importModalRef}
            className="bg-white rounded-lg shadow-lg w-[425px] p-6"
          >
            <div className="flex justify-between items-center border-b pb-2 mb-4">
              <h3 className="text-lg font-semibold">Student</h3>
              <GiCancel
                className="text-2xl hover:cursor-pointer hover:text-zinc-700"
                onClick={() => {
                  setIsImportOpen(false);
                  setFile(null);
                  setF_id(null);
                }}
              />
            </div>
            <div className="grid grid-cols-4 items-center gap-4">
              <Label className="text-right">Faculty</Label>
              <Select onValueChange={(e) => setF_id(e)} value={f_id || ""}>
                <SelectTrigger className="col-span-3">
                  <SelectValue placeholder="Faculty" />
                </SelectTrigger>
                <SelectContent>
                  {facultyData?.map((item) => (
                    <SelectItem key={item.f_id} value={item.f_id}>
                      {item.f_name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
            <div className="font-bahnschriftCon pl-5 mt-3">
              <h2 className="font-semibold">Instructions</h2>
              <ul className="list-disc text-sm">
                <li>Ensure the file is in CSV format.</li>
                <li>
                  The first row must be a header row, and the columns must be in
                  the following exact order:
                  <ol className="list-decimal list-inside">
                    <li>
                      <strong>Name</strong>
                    </li>
                    <li>
                      <strong>User name</strong>
                    </li>
                    <li>
                      <strong>Index no</strong>
                    </li>
                    <li>
                      <strong>Email</strong>
                    </li>
                    <li>
                      <strong>Contact no</strong>
                    </li>
                  </ol>
                </li>
                <li>
                  Each row after the header must represent a single student.
                </li>
              </ul>
            </div>

            <div className="grid gap-4 py-4">
              <Dropzone file={file} setFile={setFile} />
            </div>
            <div className="flex justify-end space-x-2 mt-4">
              <Button
                type="button"
                disabled={!file || !f_id || isLoading}
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

export default ImportModel;
