"use client";

import { toast } from "sonner";
import { Button } from "@/components/ui/button";
import { useEffect, useState } from "react";
import { useMutation, useQueryClient } from "@tanstack/react-query";
import {
  MultipleStudentsRegister,
  studentRegister,
} from "@/utils/apiRequests/auth.api";
import { GiCancel } from "react-icons/gi";
import Dropzone from "@/components/Dropzone";

const ImportModel = ({ isImportOpen, setIsImportOpen, importModalRef }) => {
  const queryClient = useQueryClient();
  const [file, setFile] = useState(null); // Store the dropped file

  const { status, mutate } = useMutation({
    mutationFn: MultipleStudentsRegister,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["students"]);
      toast(res.message);
    },
    onError: (err) => {
      console.log(err);
      toast("Operation failed");
    },
  });

  const onFormSubmitted = () => {
    const formData = new FormData();
    formData.append("file", file);

    mutate(formData);
    setFile(null);
    setIsImportOpen(false);
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
                }}
              />
            </div>

            <div className="grid gap-4 py-4">
              <Dropzone file={file} setFile={setFile} />
            </div>

            <div className="flex justify-end space-x-2 mt-4">
              <Button type="button" disabled={!file} onClick={onFormSubmitted}>
                Import
              </Button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default ImportModel;
