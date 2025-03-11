"use client";
import {
  Table,
  TableBody,
  TableCaption,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table";
import { Badge } from "@/components/ui/badge";
import { Button } from "@/components/ui/button";
import Link from "next/link";
import {
  Card,
  CardDescription,
  CardHeader,
  CardTitle,
} from "@/components/ui/card";
import { usePathname, useRouter } from "next/navigation";
import { useUser } from "@/utils/useUser";
import { useQuery } from "@tanstack/react-query";
import {
  getAllActiveBatchesProgesses,
  getAllBatchesForDepartment,
  getAllBatchesForFaculty,
  getBatchesByStudent,
  getBatchFullDetails,
} from "@/utils/apiRequests/batch.api";
import { useEffect, useState } from "react";
import {
  createSubjectObject,
  numberToOrdinalWord,
  parseString,
  titleCase,
} from "@/utils/functions";
import CryptoJS from "crypto-js";
import {
  getAllSubjectsForDepartment,
  getAllSubjectsForFaculty,
  getAllSubjectsForManager,
  getCurriculumBybatchId,
} from "@/utils/apiRequests/curriculum.api";
import {
  fetchStudentWithSubjectsByUserId,
  getBatchAdmissionDetails,
  getDeanDashboardData,
  getHodDashboardData,
} from "@/utils/apiRequests/entry.api";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";
import ReactDOM from "react-dom";
import AdmissionCard from "@/components/AdmissionCard";
import { createRoot } from "react-dom/client";
import ReportTable from "@/components/ReportTable";
import BatchProgress from "./BatchProgress";
import { getSummaryData } from "@/utils/apiRequests/user.api";
import SummaryCard from "./SummaryCard";
import { Skeleton } from "@/components/ui/skeleton";

const dashboard = () => {
  const pathname = usePathname();
  const { data: user, isLoading } = useUser();
  const router = useRouter();
  const [downloadBatchId, setDownloadBatchId] = useState(null);
  const [formData, setFormData] = useState({
    batch_id: "",
    generated_date: "",
    subjects: [],
    date: [],
    description: "",
    instructions: "",
    provider: "",
  });
  const [level_ordinal, setLevel_ordinal] = useState("");
  const [sem_ordinal, setSem_ordinal] = useState("");
  const [decodeBatchCode, setDecodeBatchCode] = useState({});
  const [subjectObject, setSubjectObject] = useState({});
  const [generating, setGenerating] = useState(false);
  const [showMore, setShowMore] = useState(false);

  const onDownloadClick = (batch_id) => {
    setDownloadBatchId(batch_id);
  };

  const onApplyClick = (e) => {
    e.preventDefault();
    const deg = e.currentTarget.dataset.deg;
    const sem = e.currentTarget.dataset.sem;
    const secretKey = process.env.NEXT_PUBLIC_CRYPTO_SECRET;
    const degEncryptedData = CryptoJS.AES.encrypt(
      JSON.stringify(deg),
      secretKey
    ).toString();
    const semEncryptedData = CryptoJS.AES.encrypt(
      JSON.stringify(sem),
      secretKey
    ).toString();
    router.push(
      `/home/form?deg=${encodeURIComponent(
        degEncryptedData
      )}&sem=${encodeURIComponent(semEncryptedData)}`
    );
  };

  // All queries initialized here
  const {
    data: allActiveBatchesProgessesData,
    refetch: allActiveBatchesProgessesRefetch,
  } = useQuery({
    queryFn: getAllActiveBatchesProgesses,
    queryKey: ["allActiveBatchesProgesses"],
    enabled: false,
  });

  const { data: adminSummaryData, refetch: adminSummaryRefetch } = useQuery({
    queryFn: getSummaryData,
    queryKey: ["adminSummary"],
    enabled: false,
  });

  const {
    data: bathchesOfStudentData,
    refetch: batchDataRefetch,
    isLoading: isBathchesOfStudentLoading,
  } = useQuery({
    queryFn: getBatchesByStudent,
    queryKey: ["batchesOfStudent"],
    enabled: false,
  });

  const {
    data: subjectsOfManagerData,
    refetch: subjectsOfManagerRefetch,
    isLoading: isSubjectsOfManagerLoading,
  } = useQuery({
    queryFn: getAllSubjectsForManager,
    queryKey: ["subjectsOfManager"],
    enabled: false,
  });

  const {
    data: batchesOfFacultyData,
    refetch: batchesOfFacultyRefetch,
    isLoading: isBatchesOfFacultyLoading,
  } = useQuery({
    queryFn: getAllBatchesForFaculty,
    queryKey: ["batchesOfFaculty"],
    enabled: false,
  });

  const {
    data: batchesOfDepartmentData,
    refetch: batchesOfDepartmentRefetch,
    isLoading: isBatchesOfDepartmenLoading,
  } = useQuery({
    queryFn: getAllBatchesForDepartment,
    queryKey: ["batchesOfDepartment"],
    enabled: false,
  });

  const {
    data: batchAdmissionDetailsData,
    refetch: batchAdmissionDetailsRefetch,
  } = useQuery({
    queryFn: () => getBatchAdmissionDetails(downloadBatchId),
    queryKey: ["batchAdmissionDetails"],
    enabled: false,
  });

  const { data: batchCurriculumData, refetch: batchCurriculumRefetch } =
    useQuery({
      queryFn: () => getCurriculumBybatchId(downloadBatchId),
      queryKey: ["batchCurriculum"],
      enabled: false,
    });

  const { data: batchFullDetailsData, refetch: batchFullDetailsRefetch } =
    useQuery({
      queryFn: () => getBatchFullDetails(downloadBatchId),
      queryKey: ["batchFullDetails"],
      enabled: false,
    });

  const { data: studentWithSubjectsData, refetch: studentWithSubjectsRefetch } =
    useQuery({
      queryFn: () => fetchStudentWithSubjectsByUserId(downloadBatchId),
      queryKey: ["studentsWithSubjects"],
      enabled: false,
    });

  useEffect(() => {
    if (downloadBatchId) {
      batchAdmissionDetailsRefetch();
      batchCurriculumRefetch();
      studentWithSubjectsRefetch();
      batchFullDetailsRefetch();
    }
  }, [downloadBatchId]);

  // Data Transformation
  useEffect(() => {
    if (batchAdmissionDetailsData) {
      const transformedSubjects = batchAdmissionDetailsData.subject_list
        ?.split(",")
        .map((comSubs) => comSubs.split(":"));
      const transformedDate = batchAdmissionDetailsData.exam_date
        ?.split(",")
        .map((item) => {
          const [year, months] = item.split(":");
          return {
            year: parseInt(year),
            months: months.split(";"),
          };
        });
      setFormData({
        batch_id: batchAdmissionDetailsData.batch_id,
        generated_date: batchAdmissionDetailsData.generated_date,
        subjects: transformedSubjects,
        date: transformedDate,
        description: batchAdmissionDetailsData.description,
        instructions: batchAdmissionDetailsData.instructions,
        provider: batchAdmissionDetailsData.provider,
      });
    }
  }, [batchAdmissionDetailsData]);

  useEffect(() => {
    setSubjectObject(createSubjectObject(batchCurriculumData));
  }, [batchCurriculumData]);

  useEffect(() => {
    if (batchFullDetailsData) {
      setDecodeBatchCode(parseString(batchFullDetailsData.batch_code));
    }
  }, [batchFullDetailsData]);

  useEffect(() => {
    if (decodeBatchCode) {
      setLevel_ordinal(numberToOrdinalWord(decodeBatchCode.level));
      setSem_ordinal(numberToOrdinalWord(decodeBatchCode.sem_no));
    }
  }, [decodeBatchCode]);

  const generateAdmissionCardPDFs = async (studentData) => {
    setDownloadBatchId(null);
    if (typeof document === "undefined") {
      console.error("This function can only run in a browser environment.");
      return;
    }
    setGenerating(true);
    const pdf = new jsPDF("p", "mm", "a4");

    // Create a div element to render the admission card
    const container = document.createElement("div");
    container.style.width = "210mm"; // A4 width
    container.style.height = "297mm"; // A4 height
    container.style.padding = "20px";
    container.style.backgroundColor = "#fff";
    container.id = `admission-card-${studentData?.s_id}`;
    document.body.appendChild(container);

    // Render the Admission Card
    const root = createRoot(container);
    const renderComplete = new Promise((resolve) => {
      root.render(
        <AdmissionCard
          student={studentData}
          level_ordinal={level_ordinal}
          batchFullDetailsData={batchFullDetailsData}
          decodeBatchCode={decodeBatchCode}
          formData={formData}
          sem_ordinal={sem_ordinal}
          subjectObject={subjectObject}
          onRenderComplete={resolve}
        />
      );
    });

    await renderComplete;

    // Convert the admission card to canvas
    const canvas = await html2canvas(container, {
      scale: 2, // Enhance image quality
      useCORS: true, // Enable cross-origin image handling
    });

    const imgData = canvas.toDataURL("image/png");
    const imgProps = pdf.getImageProperties(imgData);
    const pdfWidth = pdf.internal.pageSize.getWidth();
    const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

    // Add the image to the PDF
    pdf.addImage(imgData, "PNG", 0, 0, pdfWidth, pdfHeight);

    // pdf.addPage();

    // Clean up the DOM after rendering the canvas
    document.body.removeChild(container);

    // Save the PDF for the current exam type
    pdf.save(`${studentData.index_num}_admission_card.pdf`);
    setGenerating(false);
  };

  useEffect(() => {
    downloadBatchId &&
      studentWithSubjectsData &&
      Object.keys(studentWithSubjectsData).length &&
      batchAdmissionDetailsData &&
      Object.keys(batchAdmissionDetailsData).length &&
      subjectObject &&
      Object.keys(subjectObject).length &&
      decodeBatchCode &&
      Object.keys(decodeBatchCode).length &&
      batchFullDetailsData &&
      Object.keys(batchFullDetailsData).length &&
      generateAdmissionCardPDFs(studentWithSubjectsData);
  }, [
    downloadBatchId,
    studentWithSubjectsData,
    studentWithSubjectsData,
    batchAdmissionDetailsData,
    batchAdmissionDetailsData,
    subjectObject,
    subjectObject,
    decodeBatchCode,
    decodeBatchCode,
    batchFullDetailsData,
    batchFullDetailsData,
  ]);

  if (!user) return null;

  // Conditional Rendering Based on Role
  switch (user.role_id) {
    case "1":
      allActiveBatchesProgessesRefetch();
      adminSummaryRefetch();

      return (
        <div className="flex justify-end md:justify-center">
          <div className="md:w-[70%]">
            {adminSummaryData && (
              <div className="flex gap-6 flex-wrap items-center justify-center mb-8">
                <SummaryCard
                  title={adminSummaryData.batch_count}
                  desc="Batches"
                />
                <SummaryCard
                  title={adminSummaryData.curriculum_count}
                  desc="Curriculums"
                />
                <SummaryCard
                  title={adminSummaryData.manager_count}
                  desc="Managers"
                />
                <SummaryCard
                  title={adminSummaryData.student_count}
                  desc="Students"
                />
                <SummaryCard
                  title={adminSummaryData.faculty_count}
                  desc="Faculties"
                />
                <SummaryCard
                  title={adminSummaryData.department_count}
                  desc="Departments"
                />
                <SummaryCard
                  title={adminSummaryData.degree_count}
                  desc="Degrees"
                />
              </div>
            )}
            {allActiveBatchesProgessesData &&
              allActiveBatchesProgessesData.length && (
                <div className="container mx-auto mb-3">
                  <h1 className="text-center text-3xl uppercase">
                    A list of active batches
                  </h1>
                  <Table>
                    <TableHeader>
                      <TableRow>
                        <TableHead className="w-[200px]">Batch</TableHead>
                        <TableHead className="text-center">Progress</TableHead>
                      </TableRow>
                    </TableHeader>
                    <TableBody>
                      {allActiveBatchesProgessesData &&
                        allActiveBatchesProgessesData.length &&
                        (allActiveBatchesProgessesData.length > 5 &&
                        !showMore ? (
                          <>
                            {allActiveBatchesProgessesData
                              .slice(0, 5)
                              .map((obj, i) => {
                                if (obj.admission_id && obj.attendance_id) {
                                  return (
                                    <TableRow key={i}>
                                      <TableCell className="font-medium">
                                        {obj.batch_code}
                                      </TableCell>
                                      <TableCell>
                                        <BatchProgress task="done" />
                                      </TableCell>
                                    </TableRow>
                                  );
                                }

                                if (obj.btp_data) {
                                  const btpData = obj.btp_data
                                    .split(",")
                                    .map((pair) => [
                                      pair.split(";")[0].trim(),
                                      pair.split(";")[1].trim(),
                                    ]);

                                  const deanDeadline = btpData.find(
                                    (arr) => arr[0] == "2"
                                  )[1];
                                  if (new Date() > new Date(deanDeadline)) {
                                    return (
                                      <TableRow key={i}>
                                        <TableCell className="font-medium">
                                          {obj.batch_code}
                                        </TableCell>
                                        <TableCell>
                                          <BatchProgress task="adm" />
                                        </TableCell>
                                      </TableRow>
                                    );
                                  }

                                  const hodDeadline = btpData.find(
                                    (arr) => arr[0] == "3"
                                  )[1];
                                  if (new Date() > new Date(hodDeadline)) {
                                    return (
                                      <TableRow key={i}>
                                        <TableCell className="font-medium">
                                          {obj.batch_code}
                                        </TableCell>
                                        <TableCell>
                                          <BatchProgress task="dean" />
                                        </TableCell>
                                      </TableRow>
                                    );
                                  }

                                  const lecDeadline = btpData.find(
                                    (arr) => arr[0] == "4"
                                  )[1];
                                  if (new Date() > new Date(lecDeadline)) {
                                    return (
                                      <TableRow key={i}>
                                        <TableCell className="font-medium">
                                          {obj.batch_code}
                                        </TableCell>
                                        <TableCell>
                                          <BatchProgress task="hod" />
                                        </TableCell>
                                      </TableRow>
                                    );
                                  }

                                  const stuDeadline = btpData.find(
                                    (arr) => arr[0] == "5"
                                  )[1];
                                  if (new Date() > new Date(stuDeadline)) {
                                    return (
                                      <TableRow key={i}>
                                        <TableCell className="font-medium">
                                          {obj.batch_code}
                                        </TableCell>
                                        <TableCell>
                                          <BatchProgress task="lec" />
                                        </TableCell>
                                      </TableRow>
                                    );
                                  }

                                  return (
                                    <TableRow key={i}>
                                      <TableCell className="font-medium">
                                        {obj.batch_code}
                                      </TableCell>
                                      <TableCell>
                                        <BatchProgress task="stu" />
                                      </TableCell>
                                    </TableRow>
                                  );
                                } else {
                                  return (
                                    <TableRow key={i}>
                                      <TableCell className="font-medium">
                                        {obj.batch_code}
                                      </TableCell>
                                      <TableCell>
                                        <BatchProgress task="" />
                                      </TableCell>
                                    </TableRow>
                                  );
                                }
                              })}
                            <h1>
                              <p
                                className="cursor-pointer text-blue-600"
                                onClick={() => setShowMore(true)}
                              >
                                Show more
                              </p>
                            </h1>
                          </>
                        ) : (
                          <>
                            {allActiveBatchesProgessesData.map((obj, i) => {
                              if (obj.admission_id && obj.attendance_id) {
                                return (
                                  <TableRow key={i}>
                                    <TableCell className="font-medium">
                                      {obj.batch_code}
                                    </TableCell>
                                    <TableCell>
                                      <BatchProgress task="done" />
                                    </TableCell>
                                  </TableRow>
                                );
                              }

                              if (obj.btp_data) {
                                const btpData = obj.btp_data
                                  .split(",")
                                  .map((pair) => [
                                    pair.split(";")[0].trim(),
                                    pair.split(";")[1].trim(),
                                  ]);

                                const deanDeadline = btpData.find(
                                  (arr) => arr[0] == "2"
                                )[1];
                                if (new Date() > new Date(deanDeadline)) {
                                  return (
                                    <TableRow key={i}>
                                      <TableCell className="font-medium">
                                        {obj.batch_code}
                                      </TableCell>
                                      <TableCell>
                                        <BatchProgress task="adm" />
                                      </TableCell>
                                    </TableRow>
                                  );
                                }

                                const hodDeadline = btpData.find(
                                  (arr) => arr[0] == "3"
                                )[1];
                                if (new Date() > new Date(hodDeadline)) {
                                  return (
                                    <TableRow key={i}>
                                      <TableCell className="font-medium">
                                        {obj.batch_code}
                                      </TableCell>
                                      <TableCell>
                                        <BatchProgress task="dean" />
                                      </TableCell>
                                    </TableRow>
                                  );
                                }

                                const lecDeadline = btpData.find(
                                  (arr) => arr[0] == "4"
                                )[1];
                                if (new Date() > new Date(lecDeadline)) {
                                  return (
                                    <TableRow key={i}>
                                      <TableCell className="font-medium">
                                        {obj.batch_code}
                                      </TableCell>
                                      <TableCell>
                                        <BatchProgress task="hod" />
                                      </TableCell>
                                    </TableRow>
                                  );
                                }

                                const stuDeadline = btpData.find(
                                  (arr) => arr[0] == "5"
                                )[1];
                                if (new Date() > new Date(stuDeadline)) {
                                  return (
                                    <TableRow key={i}>
                                      <TableCell className="font-medium">
                                        {obj.batch_code}
                                      </TableCell>
                                      <TableCell>
                                        <BatchProgress task="lec" />
                                      </TableCell>
                                    </TableRow>
                                  );
                                }

                                return (
                                  <TableRow key={i}>
                                    <TableCell className="font-medium">
                                      {obj.batch_code}
                                    </TableCell>
                                    <TableCell>
                                      <BatchProgress task="stu" />
                                    </TableCell>
                                  </TableRow>
                                );
                              } else {
                                return (
                                  <TableRow key={i}>
                                    <TableCell className="font-medium">
                                      {obj.batch_code}
                                    </TableCell>
                                    <TableCell>
                                      <BatchProgress task="" />
                                    </TableCell>
                                  </TableRow>
                                );
                              }
                            })}
                            {allActiveBatchesProgessesData.length > 5 ? (
                              <h1>
                                <p
                                  className="cursor-pointer text-blue-600"
                                  onClick={() => setShowMore(false)}
                                >
                                  Show less
                                </p>
                              </h1>
                            ) : (
                              ""
                            )}
                          </>
                        ))}
                    </TableBody>
                  </Table>
                </div>
              )}
          </div>
        </div>
      );
    case "2":
      batchesOfFacultyRefetch();

      if (isBatchesOfFacultyLoading)
        return (
          <div className="flex justify-end md:justify-center">
            <div className="md:w-[70%] flex gap-6 flex-wrap">
              {[1, 2, 3, 4, 5, 6].map((_, i) => (
                <Skeleton
                  key={i}
                  className="w-[30%] h-32 max-w-[30%] rounded-xl"
                />
              ))}
            </div>
          </div>
        );

      return (
        <div className="flex justify-end md:justify-center">
          <div className="md:w-[70%] flex gap-6 flex-wrap">
            {batchesOfFacultyData && batchesOfFacultyData.length ? (
              batchesOfFacultyData.map((obj) => {
                const decodeBatchCode = parseString(obj.batch_code);
                const level_ordinal = numberToOrdinalWord(
                  decodeBatchCode.level
                );
                const sem_ordinal = numberToOrdinalWord(decodeBatchCode.sem_no);
                return (
                  <Link
                    href={{
                      pathname: `${pathname}/batches/${obj.batch_code}`,
                      query: {
                        batch_id: obj.batch_id,
                      },
                    }}
                    className="min-w-[30%] max-w-[30%] hover:shadow-md rounded-xl"
                    key={obj.batch_id}
                  >
                    <Card>
                      <CardHeader>
                        <CardTitle className="capitalize text-center">
                          <p>
                            {level_ordinal} examination in {obj.deg_name}
                          </p>
                          <p>{decodeBatchCode.academic_year}</p>
                          <br />
                          <p>{sem_ordinal} semester</p>
                        </CardTitle>
                        <CardDescription className="capitalize text-center">
                          {obj.batch_code}
                        </CardDescription>
                      </CardHeader>
                    </Card>
                  </Link>
                );
              })
            ) : (
              <h1 className="text-2xl text-center w-full">
                No batches available!
              </h1>
            )}
          </div>
        </div>
      );

    case "3":
      batchesOfDepartmentRefetch();

      if (isBatchesOfDepartmenLoading)
        return (
          <div className="flex justify-end md:justify-center">
            <div className="md:w-[70%] flex gap-6 flex-wrap">
              {[1, 2, 3, 4, 5, 6].map((_, i) => (
                <Skeleton
                  key={i}
                  className="w-[30%] h-32 max-w-[30%] rounded-xl"
                />
              ))}
            </div>
          </div>
        );

      return (
        <div className="flex justify-end md:justify-center">
          <div className="md:w-[70%] flex gap-6 flex-wrap">
            {batchesOfDepartmentData && batchesOfDepartmentData.length ? (
              batchesOfDepartmentData.map((obj) => {
                const decodeBatchCode = parseString(obj.batch_code);
                const level_ordinal = numberToOrdinalWord(
                  decodeBatchCode.level
                );
                const sem_ordinal = numberToOrdinalWord(decodeBatchCode.sem_no);
                return (
                  <Link
                    href={{
                      pathname: `${pathname}/batches/${obj.batch_code}`,
                      query: {
                        batch_id: obj.batch_id,
                      },
                    }}
                    className="min-w-[30%] max-w-[30%] hover:shadow-md rounded-xl"
                    key={obj.batch_id}
                  >
                    <Card>
                      <CardHeader>
                        <CardTitle className="capitalize text-center">
                          <p>
                            {level_ordinal} examination in {obj.deg_name}
                          </p>
                          <p>{decodeBatchCode.academic_year}</p>
                          <br />
                          <p>{sem_ordinal} semester</p>
                        </CardTitle>
                        <CardDescription className="capitalize text-center">
                          {obj.batch_code}
                        </CardDescription>
                      </CardHeader>
                    </Card>
                  </Link>
                );
              })
            ) : (
              <h1 className="text-2xl text-center w-full">
                No batches available!
              </h1>
            )}
          </div>
        </div>
      );
    case "4":
      subjectsOfManagerRefetch();

      if (isSubjectsOfManagerLoading)
        return (
          <div className="flex justify-end md:justify-center">
            <div className="md:w-[70%] flex gap-6 flex-wrap">
              {[1, 2, 3, 4, 5, 6].map((_, i) => (
                <Skeleton
                  key={i}
                  className="w-[30%] h-32 max-w-[30%] rounded-xl"
                />
              ))}
            </div>
          </div>
        );

      return (
        <div className="flex justify-end md:justify-center">
          <div className="md:w-[70%] flex gap-6 flex-wrap">
            {subjectsOfManagerData && subjectsOfManagerData.length ? (
              subjectsOfManagerData.map((obj) => (
                <Link
                  href={{
                    pathname: `${pathname}/subjects/${obj.sub_code}`,
                    query: {
                      sub_id: obj.sub_id,
                      batch_id: obj.batch_id,
                      deadline: obj.deadline,
                    },
                  }}
                  className="w-[30%] max-w-[30%] hover:shadow-md rounded-xl"
                  key={obj.sub_id}
                >
                  <Card>
                    <CardHeader>
                      <CardTitle>{titleCase(obj.sub_name)}</CardTitle>
                      <CardDescription>{obj.sub_code}</CardDescription>
                    </CardHeader>
                  </Card>
                </Link>
              ))
            ) : (
              <h1 className="text-2xl text-center w-full">
                No entries available!
              </h1>
            )}
          </div>
        </div>
      );

    case "5":
      batchDataRefetch();

      return (
        <div className="flex justify-center relative">
          <div
            className={`${
              generating ? "fixed" : "hidden"
            } left-0 top-0 w-full h-full flex justify-center items-center bg-white/35 z-50`}
          >
            <img
              className="w-20 h-20 animate-spin "
              src="https://www.svgrepo.com/show/491270/loading-spinner.svg"
              alt="Loading icon"
            />
          </div>

          <div className="hidden sm:block w-[90%] lg:w-[75%] rounded-md bg-white">
            <Table>
              <TableCaption>A list of your recent examinations.</TableCaption>
              <TableHeader>
                <TableRow>
                  <TableHead>Examination</TableHead>
                  <TableHead className="w-[150px]">Status</TableHead>
                  <TableHead className="w-[230px] text-center">
                    Actions
                  </TableHead>
                  <TableHead className="w-[150px]">Deadline</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {bathchesOfStudentData?.length &&
                  bathchesOfStudentData?.map((batch) => {
                    const decodeBatchCode = parseString(batch.batch_code);
                    const level_ordinal = numberToOrdinalWord(
                      decodeBatchCode.level
                    );
                    const sem_ordinal = numberToOrdinalWord(
                      decodeBatchCode.sem_no
                    );

                    return (
                      <TableRow key={batch.batch_id}>
                        <TableCell className="font-medium uppercase">
                          {level_ordinal} examination in {batch.deg_name} -{" "}
                          {decodeBatchCode.academic_year} {sem_ordinal}
                          &nbsp;semester
                        </TableCell>
                        <TableCell>
                          <Badge
                            variant={
                              batch.status === "done"
                                ? "success"
                                : batch.status === "pending"
                                ? "pending"
                                : batch.status === "expired"
                                ? "failure"
                                : "active"
                            }
                            className="uppercase"
                          >
                            {batch.status}
                          </Badge>
                        </TableCell>
                        <TableCell>
                          <div className="flex justify-around items-center h-full">
                            {batch.status == "active" ? (
                              <Button
                                variant="outline"
                                className="uppercase"
                                data-deg={`${level_ordinal} examination in ${batch.deg_name} - ${decodeBatchCode.academic_year}`}
                                data-sem={`${sem_ordinal} semester`}
                                onClick={(e) => onApplyClick(e)}
                              >
                                apply
                              </Button>
                            ) : (
                              <Button
                                variant="outline"
                                className="uppercase"
                                disabled={true}
                              >
                                apply
                              </Button>
                            )}
                            {batch.admission_ready == "false" ||
                            batch.applied_to_exam == "false" ? (
                              <Button
                                variant="outline"
                                className="uppercase"
                                disabled={true}
                              >
                                download
                              </Button>
                            ) : (
                              <Button
                                variant="outline"
                                className="uppercase"
                                onClick={() => onDownloadClick(batch.batch_id)}
                              >
                                download
                              </Button>
                            )}
                          </div>
                        </TableCell>
                        <TableCell>
                          {new Date(batch.deadline)
                            .toString()
                            .slice(
                              4,
                              new Date(batch.deadline).toString().indexOf("GMT")
                            )}
                        </TableCell>
                      </TableRow>
                    );
                  })}
              </TableBody>
            </Table>
          </div>
          <div className="sm:hidden flex flex-col items-center gap-3">
            {isBathchesOfStudentLoading &&
              [1, 2, 3, 4].map((_, i) => (
                <Skeleton key={i} className="w-full h-48 rounded-md" />
              ))}

            {bathchesOfStudentData?.length &&
              bathchesOfStudentData?.map((batch) => {
                const decodeBatchCode = parseString(batch.batch_code);
                const level_ordinal = numberToOrdinalWord(
                  decodeBatchCode.level
                );
                const sem_ordinal = numberToOrdinalWord(decodeBatchCode.sem_no);

                return (
                  <div
                    className=" rounded-md bg-white p-3 gap-3 flex flex-col items-center"
                    key={batch.batch_id}
                  >
                    <h1 className="font-medium uppercase text-center">
                      {level_ordinal} examination in {batch.deg_name} -{" "}
                      {decodeBatchCode.academic_year} {sem_ordinal}
                      &nbsp;semester{" "}
                      <Badge
                        variant={
                          batch.status === "done"
                            ? "success"
                            : batch.status === "pending"
                            ? "pending"
                            : batch.status === "expired"
                            ? "failure"
                            : "active"
                        }
                        className="uppercase"
                      >
                        {batch.status}
                      </Badge>
                    </h1>
                    <div className="flex justify-around items-center self-stretch">
                      {batch.status == "active" ? (
                        <Button
                          variant="outline"
                          className="uppercase"
                          data-deg={`${level_ordinal} examination in ${batch.deg_name} - ${decodeBatchCode.academic_year}`}
                          data-sem={`${sem_ordinal} semester`}
                          onClick={(e) => onApplyClick(e)}
                        >
                          apply
                        </Button>
                      ) : (
                        <Button
                          variant="outline"
                          className="uppercase"
                          disabled={true}
                        >
                          apply
                        </Button>
                      )}
                      {batch.admission_ready == "false" ||
                      batch.applied_to_exam == "false" ? (
                        <Button
                          variant="outline"
                          className="uppercase"
                          disabled={true}
                        >
                          download
                        </Button>
                      ) : (
                        <Button
                          variant="outline"
                          className="uppercase"
                          onClick={() => onDownloadClick(batch.batch_id)}
                        >
                          download
                        </Button>
                      )}
                    </div>
                    <div className="flex flex-col items-center justify-center">
                      <span className="font-semibold">Deadline</span>
                      {new Date(batch.deadline)
                        .toString()
                        .slice(
                          4,
                          new Date(batch.deadline).toString().indexOf("GMT")
                        )}
                    </div>
                  </div>
                );
              })}
          </div>
        </div>
      );
  }
};

export default dashboard;
