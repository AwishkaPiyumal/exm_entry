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
  getAllFaculties,
  getDegreeById,
  getDegreesByDepartmentId,
  getDepartmentsByFacultyId,
} from "@/utils/apiRequests/course.api";
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select";
import {
  createCurriculum,
  getCurriculumById,
  updateCurriculum,
} from "@/utils/apiRequests/curriculum.api";

const Model = ({ editId, isOpen, setIsOpen, modalRef, setEditId }) => {
  const [formData, setFormData] = useState({});
  const [btnEnable, setBtnEnable] = useState(false);
  const queryClient = useQueryClient();

  const { status, mutate } = useMutation({
    mutationFn: editId ? updateCurriculum : createCurriculum,
    onSuccess: (res) => {
      queryClient.invalidateQueries(["curriculumsExtra"]);
      setEditId("");
      toast.success(res.message);
    },
    onError: (err) => {
      setEditId("");
      toast.error("Operation failed");
    },
  });

  const { data, refetch } = useQuery({
    queryFn: () => getCurriculumById(editId),
    queryKey: ["curriculums", editId],
    enabled: false,
  });

  const { data: facultyData } = useQuery({
    queryFn: getAllFaculties,
    queryKey: ["activeFaculties"],
  });

  const { data: departmentData, refetch: departmentDataRefetch } = useQuery({
    queryFn: () => getDepartmentsByFacultyId(formData.f_id),
    queryKey: ["activeDepartments", "faculty", formData.f_id],
    enabled: false,
  });

  const { data: degreeData, refetch: degreeDataRefetch } = useQuery({
    queryFn: () => getDegreesByDepartmentId(formData.d_id),
    queryKey: ["activeDegrees", "department", formData.d_id],
    enabled: false,
  });

  const { data: degreeLevelsData, refetch: degreeLevelsDataRefetch } = useQuery(
    {
      queryFn: () => getDegreeById(formData.deg_id),
      queryKey: ["degrees", formData.deg_id],
      enabled: false,
    }
  );

  useEffect(() => {
    if (data) setFormData(data);
  }, [data]);

  const onFormDataChanged = (e) => {
    if (e?.target) {
      setFormData((curData) => ({
        ...curData,
        [e.target?.name]: e.target?.value,
      }));
    } else {
      setFormData((curData) => ({
        ...curData,
        [e.split(":")[0]]: e.split(":")[1],
      }));
    }
  };

  const onFormSubmitted = () => {
    mutate(formData);
    setFormData({});
    setIsOpen(false);
  };

  const onFormReset = () => {
    setFormData(data || {});
  };

  useEffect(() => {
    const isFormValid =
      formData.sub_code &&
      formData.sub_name &&
      formData.f_id &&
      formData.d_id &&
      formData.deg_id &&
      formData.sem_no &&
      formData.level;
    setBtnEnable(isFormValid);
  }, [formData]);

  useEffect(() => {
    editId && refetch();
  }, [editId]);

  useEffect(() => {
    if (formData?.f_id) departmentDataRefetch();
  }, [formData?.f_id]);

  useEffect(() => {
    if (formData?.d_id) degreeDataRefetch();
  }, [formData?.d_id]);

  useEffect(() => {
    if (formData?.deg_id) degreeLevelsDataRefetch();
  }, [formData?.deg_id]);

  return (
    <>
      {isOpen && (
        <div className="fixed inset-0 flex items-center justify-center bg-black bg-opacity-50 z-50">
          <div
            ref={modalRef}
            className="bg-white rounded-lg shadow-lg w-[425px] p-6"
          >
            <div className="flex justify-between items-center border-b pb-2 mb-4">
              <h3 className="text-lg font-semibold">Subject</h3>

              <GiCancel
                className="text-2xl hover:cursor-pointer hover:text-zinc-700"
                onClick={() => {
                  setIsOpen(false);
                  setFormData({});
                  setEditId("");
                }}
              />
            </div>
            <div className="grid gap-4 py-4">
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="sub_code" className="text-right">
                  Subject Code
                </Label>
                <Input
                  id="sub_code"
                  name="sub_code"
                  className="col-span-3"
                  onChange={(e) => onFormDataChanged(e)}
                  onBlur={(e) => {
                    e.target.value = e.target.value.trim();
                    onFormDataChanged(e);
                  }}
                  value={formData.sub_code || ""}
                />
              </div>
              <div className="grid grid-cols-4 items-center gap-4">
                <Label htmlFor="sub_name" className="text-right">
                  Subject name
                </Label>
                <Input
                  id="sub_name"
                  name="sub_name"
                  className="col-span-3"
                  onChange={(e) => onFormDataChanged(e)}
                  onBlur={(e) => {
                    e.target.value = e.target.value.trim();
                    onFormDataChanged(e);
                  }}
                  value={formData.sub_name || ""}
                />
              </div>
              <div className={`grid grid-cols-4 items-center gap-4`}>
                <Label className="text-right">Faculty</Label>
                <Select
                  onValueChange={(e) => {
                    setFormData((cur) => ({ ...cur, d_id: "" }));
                    onFormDataChanged(e);
                  }}
                  value={formData.f_id ? "f_id:" + formData.f_id : ""}
                >
                  <SelectTrigger className="col-span-3">
                    <SelectValue placeholder="Faculty" />
                  </SelectTrigger>
                  <SelectContent>
                    {facultyData?.map((item) => (
                      <SelectItem value={`f_id:${item.f_id}`} key={item.f_id}>
                        {item.f_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className={`grid grid-cols-4 items-center gap-4`}>
                <Label className="text-right">Department</Label>
                <Select
                  onValueChange={(e) => {
                    setFormData((cur) => ({ ...cur, deg_id: "" }));
                    onFormDataChanged(e);
                  }}
                  value={formData.d_id ? "d_id:" + formData.d_id : ""}
                  disabled={!formData.f_id}
                >
                  <SelectTrigger className="col-span-3">
                    <SelectValue placeholder="Department" />
                  </SelectTrigger>
                  <SelectContent>
                    {departmentData?.map((item) => (
                      <SelectItem key={item.d_id} value={`d_id:${item.d_id}`}>
                        {item.d_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className={`grid grid-cols-4 items-center gap-4`}>
                <Label className="text-right">Degree programme</Label>
                <Select
                  onValueChange={(e) => {
                    onFormDataChanged(e);
                  }}
                  value={formData.deg_id ? "deg_id:" + formData.deg_id : ""}
                  disabled={!formData.d_id}
                >
                  <SelectTrigger className="col-span-3">
                    <SelectValue placeholder="Degree programme" />
                  </SelectTrigger>
                  <SelectContent>
                    {degreeData?.map((item) => (
                      <SelectItem
                        key={item.deg_id}
                        value={`deg_id:${item.deg_id}`}
                      >
                        {item.deg_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              <div
                className={`${
                  degreeLevelsData ? "grid" : "hidden"
                }  grid-cols-4 gap-4`}
              >
                <Label className="text-right">Level</Label>
                <div className="flex col-span-3 gap-4 flex-wrap">
                  {degreeLevelsData?.levels.map((item) => (
                    <div className="flex items-center space-x-2" key={item}>
                      <input
                        type="radio"
                        value={item}
                        id={`l${item}`}
                        checked={formData.level == item}
                        name="level"
                        onChange={(e) => onFormDataChanged(e)}
                        className="h-4 w-4 shadow focus:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 accent-black"
                      />
                      <Label htmlFor={`l${item}`} className="cursor-pointer">
                        {item}
                      </Label>
                    </div>
                  ))}
                </div>
              </div>
              <div
                className={`${
                  degreeLevelsData ? "grid" : "hidden"
                }  grid-cols-4 gap-4`}
              >
                <Label className="text-right">Semester</Label>
                <div className="flex col-span-3 gap-4 flex-wrap">
                  {Array(+degreeLevelsData?.no_of_sem_per_year || 0)
                    .fill(1)
                    .map((_, ind) => (
                      <div
                        className="flex items-center space-x-2"
                        key={ind + 1}
                      >
                        <input
                          type="radio"
                          value={ind + 1}
                          id={`s${ind + 1}`}
                          checked={formData.sem_no == ind + 1}
                          name="sem_no"
                          onChange={(e) => onFormDataChanged(e)}
                          className="h-4 w-4 shadow focus:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 accent-black"
                        />
                        <Label
                          htmlFor={`s${ind + 1}`}
                          className="cursor-pointer"
                        >
                          {ind + 1}
                        </Label>
                      </div>
                    ))}
                </div>
              </div>
            </div>
            <div className="flex justify-between space-x-2 mt-4">
              <Button
                type="button"
                variant="warning"
                onClick={() => onFormReset()}
              >
                Reset
              </Button>
              <Button
                type="button"
                disabled={!btnEnable}
                onClick={onFormSubmitted}
              >
                {editId ? "Update" : "Create"}
              </Button>
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Model;
