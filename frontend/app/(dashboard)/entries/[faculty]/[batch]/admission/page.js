"use client";
import dynamic from "next/dynamic";

const AdmissionCardTemplate = dynamic(
  () => import("@/components/AdmissionCardTemplate"),
  {
    ssr: false,
  }
);
import { Button } from "@/components/ui/button";
import { getBatchFullDetails } from "@/utils/apiRequests/batch.api";
import { getCurriculumBybatchId } from "@/utils/apiRequests/curriculum.api";
import {
  createOrUpdateAdmission,
  fetchStudentsWithSubjects,
  getLatestAdmissionTemplate,
} from "@/utils/apiRequests/entry.api";
import {
  createSubjectObject,
  getModifiedDate,
  numberToOrdinalWord,
  parseString,
} from "@/utils/functions";
import { useMutation, useQuery } from "@tanstack/react-query";
import { useSearchParams } from "next/navigation";
import { useEffect, useState } from "react";
import { toast } from "sonner";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";
import ReactDOM from "react-dom";
import AdmissionCard from "@/components/AdmissionCard";
import { createRoot } from "react-dom/client";

const AdmissionPage = () => {
  const searchParams = useSearchParams();
  const batch_id = searchParams.get("batch_id");
  const [level_ordinal, setLevel_ordinal] = useState("");
  const [sem_ordinal, setSem_ordinal] = useState("");
  const [academicYear, setAcademicYear] = useState("");
  const [subjectObject, setSubjectObject] = useState({});
  const [generating, setGenerating] = useState(false);
  const [formData, setFormData] = useState({
    batch_id,
    generated_date: getModifiedDate(new Date()),
    subjects: [],
    date: [{ year: new Date().getFullYear(), months: [new Date().getMonth()] }],
    description:
      "<p>Candidates are expected to produce this admission card to the  Supervisor/Invigilator/Examiner at the Examination Hall. This form &nbsp; &nbsp; &nbsp; should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The &nbsp; Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>",
    instructions:
      "<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>",
    provider:
      "<p>Senior Asst. Registrar</p><p>Examination &amp; Student Admission</p>",
  });

  const generateAdmissionCardPDFs = async (studentsData) => {
    if (typeof document === "undefined") {
      console.error("This function can only run in a browser environment.");
      return;
    }

    try {
      setGenerating(true);

      for (const [type, students] of Object.entries(studentsData)) {
        if (students.length === 0) continue;

        const pdf = new jsPDF({
          orientation: "portrait",
          unit: "mm",
          format: "a4",
          compress: true,
        });

        const quality = 2; // Higher value = better quality

        for (let i = 0; i < students.length; i++) {
          const student = students[i];

          // Create a container with precise A4 dimensions
          const container = document.createElement("div");
          container.style.width = "210mm";
          container.style.padding = "10mm";
          container.style.backgroundColor = "#fff";
          container.style.boxSizing = "border-box";
          container.style.position = "absolute";
          container.style.left = "-9999px";
          container.id = `admission-card-${type}-${i}`;
          document.body.appendChild(container);

          // Render the component and wait for completion
          const root = createRoot(container);
          await new Promise((resolve) => {
            root.render(
              <AdmissionCard
                student={student}
                type={type}
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

          // Wait for a little extra time to ensure rendering is complete
          // await new Promise((resolve) => setTimeout(resolve, 500));

          // Use html2canvas with better settings
          const canvas = await html2canvas(container, {
            scale: quality,
            useCORS: true,
            logging: false,
            allowTaint: true,
            // imageTimeout: 2000,
          });

          // Convert canvas to image
          const imgData = canvas.toDataURL("image/jpeg", 1.0);

          // Calculate dimensions to fit the page
          const imgWidth = pdf.internal.pageSize.getWidth();
          const imgHeight = (canvas.height * imgWidth) / canvas.width;

          // Check if the content exceeds page height
          const pageHeight = pdf.internal.pageSize.getHeight();

          // If this is not the first student, add a new page
          if (i > 0) {
            pdf.addPage();
          }

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

          // Clean up by removing the container
          document.body.removeChild(container);
        }

        // Save the PDF for the current exam type
        pdf.save(
          `${batchFullDetailsData.batch_code}_${type}_admission_cards.pdf`
        );
      }
    } catch (error) {
      console.error("Error generating PDFs:", error);
    } finally {
      setGenerating(false);
    }
  };

  const { data: latestAdmissionTemplateData } = useQuery({
    queryFn: () => getLatestAdmissionTemplate(batch_id),
    queryKey: ["latestAdmissionTemplate", batch_id],
  });

  const {
    data: batchFullDetailsData,
    isLoading: isBatchDetailsLoading,
    error,
  } = useQuery({
    queryFn: () => getBatchFullDetails(batch_id),
    queryKey: ["batchFullDetails"],
  });

  const { data: studentsWithSubjectsData } = useQuery({
    queryFn: () => fetchStudentsWithSubjects(batch_id),
    queryKey: ["studentsWithSubjects"],
  });

  const { data: batchCurriculumData, isLoading: isCurriculumDataLoading } =
    useQuery({
      queryFn: () => getCurriculumBybatchId(batch_id),
      queryKey: ["batchCurriculum"],
    });

  const { status, mutate } = useMutation({
    mutationFn: createOrUpdateAdmission,
    onSuccess: (res) => {
      toast.success(res.message);
    },
    onError: (err) => {
      toast.error("Operation failed");
    },
  });

  const onGenerate = () => {
    mutate(formData);
    studentsWithSubjectsData &&
      generateAdmissionCardPDFs(studentsWithSubjectsData);
  };

  useEffect(() => {
    if (batchFullDetailsData) {
      setLevel_ordinal(numberToOrdinalWord(batchFullDetailsData.level));
      setSem_ordinal(numberToOrdinalWord(batchFullDetailsData.sem));
      setAcademicYear(batchFullDetailsData.academic_year);
    }
  }, [batchFullDetailsData]);

  useEffect(() => {
    setSubjectObject(createSubjectObject(batchCurriculumData));
  }, [batchCurriculumData]);

  return (
    <>
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

      <AdmissionCardTemplate
        batch_id={batch_id}
        setFormData={setFormData}
        formData={formData}
        batchFullDetailsData={batchFullDetailsData}
        latestAdmissionTemplateData={latestAdmissionTemplateData}
        batchCurriculumData={batchCurriculumData}
        level_ordinal={level_ordinal}
        sem_ordinal={sem_ordinal}
        academicYear={academicYear}
        subjectObject={subjectObject}
      />
      <div
        className={`${
          isBatchDetailsLoading || isCurriculumDataLoading ? "hidden " : "flex "
        } justify-center mt-8 `}
      >
        <Button
          disabled={isBatchDetailsLoading || isCurriculumDataLoading}
          onClick={onGenerate}
        >
          Generate
        </Button>
      </div>
    </>
  );
};

export default AdmissionPage;
