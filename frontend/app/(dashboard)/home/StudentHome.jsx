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
import { useUser } from "@/utils/useUser";
import { useQuery } from "@tanstack/react-query";
import {
  getBatchesByStudent,
  getBatchFullDetails,
} from "@/utils/apiRequests/batch.api";
import { useEffect, useState } from "react";
import {
  createSubjectObject,
  numberToOrdinalWord,
  parseString,
} from "@/utils/functions";
import CryptoJS from "crypto-js";
import { getCurriculumBybatchId } from "@/utils/apiRequests/curriculum.api";
import {
  fetchStudentWithSubjectsByUserId,
  getBatchAdmissionDetails,
} from "@/utils/apiRequests/entry.api";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";
import AdmissionCard from "@/components/AdmissionCard";
import { createRoot } from "react-dom/client";
import { Skeleton } from "@/components/ui/skeleton";
import { useRouter } from "next/navigation";

const StudentHome = () => {
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
  const [academicYear, setAcademicYear] = useState("");
  const [subjectObject, setSubjectObject] = useState({});
  const [generating, setGenerating] = useState(false);

  const onDownloadClick = (batch_id) => {
    setDownloadBatchId(batch_id);
  };

  const onApplyClick = (e) => {
    e.preventDefault();
    const deg = e.currentTarget.dataset.deg;
    const secretKey = process.env.NEXT_PUBLIC_CRYPTO_SECRET;
    const degEncryptedData = CryptoJS.AES.encrypt(
      JSON.stringify(deg),
      secretKey
    ).toString();

    router.push(`/home/form?deg=${encodeURIComponent(degEncryptedData)}`);
  };

  // All queries initialized here

  const { data: bathchesOfStudentData, isLoading: isBathchesOfStudentLoading } =
    useQuery({
      queryFn: getBatchesByStudent,
      queryKey: ["batchesOfStudent"],
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
      setLevel_ordinal(numberToOrdinalWord(batchFullDetailsData.level));
      setSem_ordinal(numberToOrdinalWord(batchFullDetailsData.sem));
      setAcademicYear(batchFullDetailsData.academic_year);
    }
  }, [batchFullDetailsData]);

  const generateAdmissionCardPDFs = async (studentData) => {
    setDownloadBatchId(null);
    if (typeof document === "undefined") {
      console.error("This function can only run in a browser environment.");
      return;
    }

    try {
      setGenerating(true);
      const pdf = new jsPDF({
        orientation: "portrait",
        unit: "mm",
        format: "a4",
        compress: true,
      });
      // Create a div element to render the admission card
      const container = document.createElement("div");
      container.style.width = "210mm";
      container.style.padding = "10mm";
      container.style.backgroundColor = "#fff";
      container.style.boxSizing = "border-box";
      container.style.position = "absolute";
      container.style.left = "-9999px";
      container.id = `admission-card-${studentData?.s_id}`;
      document.body.appendChild(container);

      // Render the Admission Card
      const root = createRoot(container);
      const renderComplete = new Promise((resolve) => {
        root.render(
          <AdmissionCard
            student={studentData}
            type="P"
            level_ordinal={level_ordinal}
            batchFullDetailsData={batchFullDetailsData}
            academicYear={academicYear}
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
        logging: false,
        allowTaint: true,
      });

      const imgData = canvas.toDataURL("image/jpeg", 1.0);
      // Calculate dimensions to fit the page
      const imgWidth = pdf.internal.pageSize.getWidth();
      const imgHeight = (canvas.height * imgWidth) / canvas.width;

      // Check if the content exceeds page height
      const pageHeight = pdf.internal.pageSize.getHeight();

      // Add image to PDF - ensure it fits on one page
      const contentHeight = Math.min(imgHeight, pageHeight - 10); // Subtract margin
      pdf.addImage(imgData, "JPEG", 0, 0, imgWidth, contentHeight);

      // Handle content that exceeds page height by adding additional pages
      if (imgHeight > pageHeight) {
        let heightLeft = imgHeight - pageHeight;
        let position = -pageHeight;

        while (heightLeft > 0) {
          position = position - pageHeight;
          pdf.addPage();
          pdf.addImage(imgData, "JPEG", 0, position, imgWidth, imgHeight);
          heightLeft -= pageHeight;
        }
      }

      // Clean up the DOM after rendering the canvas
      document.body.removeChild(container);

      // Save the PDF for the current exam type
      pdf.save(`${studentData.index_num}_admission_card.pdf`);
    } catch (error) {
      console.error("Error generating PDFs:", error);
    } finally {
      setGenerating(false);
    }
  };

  useEffect(() => {
    downloadBatchId &&
      studentWithSubjectsData &&
      Object.keys(studentWithSubjectsData).length &&
      batchAdmissionDetailsData &&
      Object.keys(batchAdmissionDetailsData).length &&
      subjectObject &&
      Object.keys(subjectObject).length &&
      sem_ordinal &&
      level_ordinal &&
      academicYear &&
      batchFullDetailsData &&
      Object.keys(batchFullDetailsData).length &&
      generateAdmissionCardPDFs(studentWithSubjectsData);
  }, [
    downloadBatchId,
    studentWithSubjectsData,
    batchAdmissionDetailsData,
    subjectObject,
    sem_ordinal,
    level_ordinal,
    academicYear,
    batchFullDetailsData,
  ]);

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

      <div className="hidden sm:block w-[80%] md:w-[85%] lg:w-[70%] rounded-md bg-white">
        <Table>
          <TableCaption>A list of your recent examinations.</TableCaption>
          <TableHeader>
            <TableRow>
              <TableHead>Examination</TableHead>
              <TableHead className="w-[150px]">Status</TableHead>
              <TableHead className="w-[230px] text-center">Actions</TableHead>
              <TableHead className="w-[150px]">Deadline</TableHead>
            </TableRow>
          </TableHeader>
          <TableBody>
            {bathchesOfStudentData?.length &&
              bathchesOfStudentData?.map((batch) => {
                const level_ordinal = numberToOrdinalWord(batch.level);
                const sem_ordinal = numberToOrdinalWord(batch.sem);

                if (new Date(batch.application_open) > new Date()) {
                  return (
                    <TableRow key={batch.batch_id + Math.random() * 10}>
                      <td colSpan={4}>
                        <Skeleton className="w-full h-24 rounded-sm flex flex-col justify-center items-center text-center p-2">
                          <span className="font-semibold">
                            New exam coming soon!
                          </span>
                          <h1 className="font-base uppercase text-center">
                            {level_ordinal} examination in {batch.deg_name} -{" "}
                            {batch.academic_year} - {sem_ordinal}
                            &nbsp;semester
                          </h1>
                        </Skeleton>
                      </td>
                    </TableRow>
                  );
                }

                return (
                  <TableRow key={batch.batch_id}>
                    <TableCell className="font-medium uppercase">
                      {level_ordinal} examination in {batch.deg_name} -{" "}
                      {batch.academic_year} - {sem_ordinal}
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
                            data-deg={`${level_ordinal} examination in ${batch.deg_name} - ${batch.academic_year} - ${sem_ordinal} semester`}
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
                        {/* Currently download is not available. if we need remove the "true" below at BOTH VERSION(MOBILE AND WEB) */}
                        {batch.admission_ready == "false" ||
                        batch.applied_to_exam == "false" ||
                        true ? (
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
            const level_ordinal = numberToOrdinalWord(batch.level);
            const sem_ordinal = numberToOrdinalWord(batch.sem);
            if (new Date(batch.application_open) > new Date()) {
              return (
                <Skeleton
                  key={batch.batch_id + Math.random() * 10}
                  className="w-full h-48 rounded-md flex flex-col justify-center items-center p-4 text-center"
                >
                  <span className="font-semibold">New exam coming soon!</span>
                  <h1 className="font-base uppercase text-center">
                    {level_ordinal} examination in {batch.deg_name} -{" "}
                    {batch.academic_year} - {sem_ordinal}
                    &nbsp;semester
                  </h1>
                </Skeleton>
              );
            }

            return (
              <div
                className=" rounded-md text-sm bg-white p-3 gap-3 flex flex-col items-center"
                key={batch.batch_id}
              >
                <h1 className="font-medium uppercase text-center">
                  {level_ordinal} examination in {batch.deg_name} -{" "}
                  {batch.academic_year} - {sem_ordinal}
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
                      size="sm"
                      data-deg={`${level_ordinal} examination in ${batch.deg_name} - ${batch.academic_year} - ${sem_ordinal} semester`}
                      onClick={(e) => onApplyClick(e)}
                    >
                      apply
                    </Button>
                  ) : (
                    <Button
                      variant="outline"
                      className="uppercase"
                      size="sm"
                      disabled={true}
                    >
                      apply
                    </Button>
                  )}
                  {/* Currently download is not available. if we need remove the "true" below at BOTH VERSION(MOBILE AND WEB) */}
                  {batch.admission_ready == "false" ||
                  batch.applied_to_exam == "false" ||
                  true ? (
                    <Button
                      variant="outline"
                      className="uppercase"
                      size="sm"
                      disabled={true}
                    >
                      download
                    </Button>
                  ) : (
                    <Button
                      variant="outline"
                      className="uppercase"
                      size="sm"
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
};

export default StudentHome;
