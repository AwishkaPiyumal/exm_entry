"use client";

import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import { getStudentApplicationDetails } from "@/utils/apiRequests/curriculum.api";
import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import Link from "next/link";
import { useEffect, useState } from "react";
import CryptoJS from "crypto-js";
import { useRouter } from "next/navigation";
import { applyExam } from "@/utils/apiRequests/entry.api";
import { toast } from "sonner";
import { CiCircleMinus } from "react-icons/ci";
import { FaMinusCircle } from "react-icons/fa";
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerDescription,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@/components/ui/drawer";

const Form = (request) => {
  const router = useRouter();
  const [examName, setExamName] = useState(null);
  const [removedSubjects, setRemovedSubjects] = useState([]);
  const deg = request.searchParams.deg;
  const queryClient = useQueryClient();

  useEffect(() => {
    if (deg) {
      const secretKey = process.env.NEXT_PUBLIC_CRYPTO_SECRET;
      const degBytes = CryptoJS.AES.decrypt(deg, secretKey);
      const originalDegData = JSON.parse(degBytes.toString(CryptoJS.enc.Utf8));
      setExamName(originalDegData);
    }
  }, [deg]);

  const { data: applicationData, error } = useQuery({
    queryFn: getStudentApplicationDetails,
    queryKey: ["studentApplicationDetails"],
  });

  const { status, mutate } = useMutation({
    mutationFn: () => applyExam(removedSubjects),
    onSuccess: (res) => {
      queryClient.invalidateQueries(["batchesOfStudent"]);
      toast.success(res.message);
    },
    onError: (err) => {
      toast.error("Operation failed");
    },
  });

  const onSubmit = () => {
    mutate();
    router.push("/home");
  };

  useEffect(() => {
    if (error) router.push("/home");
  }, [error]);

  return (
    <>
      {applicationData && Object.keys(applicationData).length && (
        <div className="flex justify-end md:justify-center">
          <div className="md:w-[60%] w-full">
            <div className="text-center uppercase font-bold">
              <h1 className="font-extrabold tracking-wide sm:text-lg">
                Faculty of {applicationData?.f_name}
              </h1>
              <h1 className="text-sm sm:text-base">{examName}</h1>
            </div>
            <div className="mt-6 sm:mt-12 flex flex-col sm:flex-row justify-between text-xs sm:text-sm font-semibold w-full px-2">
              <p>
                <span className="uppercase w-20 inline-block">Reg No</span>
                <span className="uppercase p-2 ">
                  {applicationData?.user_name}
                </span>
              </p>
              {applicationData?.index_num && (
                <p>
                  <span className="uppercase w-20 inline-block">Index No</span>
                  <span className="uppercase p-2">
                    {applicationData?.index_num}
                  </span>
                </p>
              )}
            </div>
            <div className="mt-0 sm:mt-3 flex text-xs sm:text-sm font-semibold  px-2">
              <p>
                <span className="uppercase w-20 inline-block">Name</span>
                <span className="uppercase p-2 ">{applicationData?.name}</span>
              </p>
            </div>
            <div className="my-5 sm:my-10 flex flex-col gap-2">
              {applicationData?.subjects?.length &&
                applicationData?.subjects
                  ?.filter(
                    (obj) => !removedSubjects.some((item) => item == obj.sub_id)
                  )
                  .map((obj, ind) => (
                    <div key={ind} className="flex gap-2 items-center">
                      <div className="flex-1 flex flex-col sm:flex-row px-3 py-2 sm:py-4 bg-white rounded-lg justify-between items-center w-full">
                        <h1 className="uppercase w-full sm:w-1/6 shrink-0 text-center text-sm sm:text-base">
                          {obj.sub_code}
                        </h1>
                        <h1 className="capitalize w-full sm:w-4/6 shrink-0 text-center text-sm sm:text-base">
                          {obj.sub_name}
                        </h1>
                        <h1 className="capitalize w-full sm:w-1/6 shrink-0 text-center text-sm sm:text-base">
                          {+obj.attendance >= 80 ? (
                            <Badge variant="success" className="capitalize">
                              eligible
                            </Badge>
                          ) : (
                            <Badge variant="failure" className="capitalize">
                              not eligible
                            </Badge>
                          )}
                        </h1>
                      </div>
                      <h1>
                        <Drawer>
                          <DrawerTrigger>
                            <FaMinusCircle
                              size={20}
                              className="text-red-500 hover:text-red-600 cursor-pointer"
                            />
                          </DrawerTrigger>
                          <DrawerContent>
                            <div className="mx-auto w-full max-w-sm">
                              <DrawerHeader>
                                <DrawerTitle>
                                  Are you absolutely sure?
                                </DrawerTitle>
                                <DrawerDescription>
                                  The subject {obj.sub_name} - {obj.sub_code}{" "}
                                  will be removed from your application. This
                                  action cannot be undone.
                                </DrawerDescription>
                              </DrawerHeader>
                              <DrawerFooter className="flex justify-center items-center flex-row">
                                <DrawerClose className="inline">
                                  {" "}
                                  <Button
                                    onClick={() =>
                                      setRemovedSubjects((cur) => {
                                        if (
                                          !removedSubjects.some(
                                            (item) => item == obj.sub_id
                                          )
                                        ) {
                                          let newArr = [...cur, obj.sub_id];
                                          return newArr;
                                        }
                                      })
                                    }
                                    className="hover:bg-red-400 bg-red-500 active:bg-red-400/75"
                                  >
                                    Remove
                                  </Button>
                                </DrawerClose>

                                <DrawerClose className="inline">
                                  <Button variant="outline">Cancel</Button>
                                </DrawerClose>
                              </DrawerFooter>
                            </div>
                          </DrawerContent>
                        </Drawer>
                      </h1>
                    </div>
                  ))}
            </div>
            <div className="flex justify-center sm:justify-end">
              {Object.keys(applicationData).length && (
                <Button
                  onClick={onSubmit}
                  className="h-8 rounded-md px-3 text-xs sm:h-9 sm:px-4 sm:py-2"
                >
                  Submit
                </Button>
              )}
            </div>
          </div>
        </div>
      )}
    </>
  );
};

export default Form;
