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
  generateIndexNumbers,
  getLastAssignedIndexNumber,
} from "@/utils/apiRequests/entry.api";
import { ScrollArea } from "@/components/ui/scroll-area";
import { Badge } from "@/components/ui/badge";

const IndexModel = ({
  isIndexOpen,
  setIsIndexOpen,
  indexModalRef,
  batch_id,
  studentsWithoutIndexNumberData,
}) => {
  const queryClient = useQueryClient();
  const [formData, setFormData] = useState({});
  const [btnEnable, setBtnEnable] = useState(false);

  const { status, mutate } = useMutation({
    mutationFn: generateIndexNumbers,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["studentsWithoutIndexNumber", batch_id]);
      toast(res.message);
    },
    onError: (err) => {
      console.log(err);
      toast("Operation failed");
    },
  });

  const {
    data: lastAssignedIndexNumberData,
    refetch: lastAssignedIndexNumberDataRefetch,
  } = useQuery({
    queryFn: () => getLastAssignedIndexNumber(formData),
    queryKey: ["lastAssignedIndexNumber"],
    enabled: false,
  });

  const onFormDataChanged = (e) => {
    if (e.target) {
      setFormData((curData) => ({
        ...curData,
        [e.target?.name]: e.target?.value,
      }));
    }
    console.log(formData);
  };

  const onStartsFromChanged = (e) => {
    let value = +e.target.value;
    if (value < +e.target.min) {
      value = +e.target.min;
    } else if (value > +e.target.max) {
      value = +e.target.max;
    }
    console.log(value);
    setFormData((curData) => ({
      ...curData,
      [e.target?.name]: value,
    }));
    e.target.value = value;
  };

  useEffect(() => {
    const isFormValid =
      formData.course && formData.batch && formData.startsFrom;
    setBtnEnable(isFormValid);
  }, [formData]);

  const onFormSubmitted = () => {
    mutate({ ...formData, batch_id });
    setIsIndexOpen(false);
    setFormData({});
  };

  useEffect(() => {
    console.log(lastAssignedIndexNumberData);
  }, [lastAssignedIndexNumberData]);

  return (
    <>
      {isIndexOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div
            ref={indexModalRef}
            className="bg-white rounded-lg shadow-lg w-[50vw] p-6"
          >
            <div className="flex justify-between items-center border-b pb-2 mb-4">
              <h3 className="text-lg font-semibold">Index no missing!</h3>

              <GiCancel
                className="text-2xl hover:cursor-pointer hover:text-zinc-700"
                onClick={() => {
                  setIsIndexOpen(false);
                  setFormData({});
                }}
              />
            </div>
            <h3 className="text-md ">
              Index numbers are missing for{" "}
              {studentsWithoutIndexNumberData.count} students.
            </h3>
            <ScrollArea className="h-[100px] w-[95%] rounded-md border p-4">
              {studentsWithoutIndexNumberData.user_names.map((user_name) => (
                <Badge className="mr-2">{user_name}</Badge>
              ))}
            </ScrollArea>

            <h3 className="text-md ">You can either:</h3>
            <ol className="list-decimal list-inside text-sm">
              <li>
                Manually update the index numbers for these{" "}
                {studentsWithoutIndexNumberData.count} students.
              </li>
              <li>Generate index numbers for all students in this list.</li>
            </ol>
            <table className="mx-auto">
              <thead>
                <tr>
                  <th className="w-16 text-sm">Course</th>
                  <th className="w-16 text-sm">Batch</th>
                  <th className="w-20 text-sm">Starts from</th>
                </tr>
              </thead>
              <tbody>
                <tr>
                  <td className="w-16 text-sm">
                    <Input
                      id="course"
                      name="course"
                      className="w-full"
                      placeholder="IT"
                      onChange={(e) => onFormDataChanged(e)}
                      onBlur={(e) => {
                        e.target.value = e.target.value.trim();
                        if (formData.course && formData.batch) {
                          lastAssignedIndexNumberDataRefetch();
                        }
                      }}
                      value={formData.course || ""}
                    />
                  </td>
                  <td className="w-16 text-sm">
                    <Input
                      id="batch"
                      name="batch"
                      className="w-full"
                      placeholder="16"
                      onChange={(e) => onFormDataChanged(e)}
                      onBlur={(e) => {
                        e.target.value = e.target.value.trim();
                        if (formData.course && formData.batch) {
                          lastAssignedIndexNumberDataRefetch();
                        }
                      }}
                      value={formData.batch || ""}
                    />
                  </td>
                  <td className="w-20 text-sm">
                    <input
                      id="startsFrom"
                      name="startsFrom"
                      min={lastAssignedIndexNumberData.lastIndex + 1 || 1}
                      max="999"
                      className="w-full flex h-9 col-span-3 rounded-md border border-input bg-transparent px-3 py-1 text-sm shadow-sm transition-colors file:border-0 file:bg-transparent file:text-sm file:font-medium file:text-foreground placeholder:text-muted-foreground focus-visible:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 text-right"
                      placeholder="001"
                      onBlur={(e) => onStartsFromChanged(e)}
                      onChange={(e) => onFormDataChanged(e)}
                      value={formData.startsFrom || ""}
                    />
                  </td>
                </tr>
              </tbody>
            </table>

            <div className="flex justify-end space-x-2 mt-4">
              <Button
                type="button"
                onClick={onFormSubmitted}
                disabled={!btnEnable}
              >
                Generate index no
              </Button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default IndexModel;
