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

const Page = () => {
  const searchParams = useSearchParams();
  const batch_id = searchParams.get("batch_id");
  const [level_ordinal, setLevel_ordinal] = useState("");
  const [sem_ordinal, setSem_ordinal] = useState("");
  const [decodeBatchCode, setDecodeBatchCode] = useState({});
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

    const margin = 10; // Top and bottom margin in mm

    for (const [type, students] of Object.entries(studentsData)) {
      if (students.length === 0) continue;

      const pdf = new jsPDF("p", "mm", "a4");
      setGenerating(true);

      for (let i = 0; i < students.length; i++) {
        const student = students[i];

        // Create a div element to render the admission card
        const container = document.createElement("div");
        container.style.width = "210mm"; // A4 width
        container.style.padding = "20px";
        container.style.backgroundColor = "#fff";
        container.id = `admission-card-${type}-${i}`;
        document.body.appendChild(container);

        const root = createRoot(container);
        const renderComplete = new Promise((resolve) => {
          root.render(
            <AdmissionCard
              student={student}
              type={type}
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

        // Calculate the total height of the rendered admission card
        const totalHeightPx = container.offsetHeight;
        const pageHeightPx = 1122; // A4 height in pixels at 96 DPI
        const scale = 2;

        let currentPage = 0;
        while (currentPage * pageHeightPx < totalHeightPx) {
          const canvas = await html2canvas(container, {
            scale,
            useCORS: true,
            height: pageHeightPx,
            y: currentPage * pageHeightPx,
            scrollY: -currentPage * pageHeightPx,
            windowWidth: container.offsetWidth,
            windowHeight: totalHeightPx,
          });

          const imgData = canvas.toDataURL("image/png");
          const imgProps = pdf.getImageProperties(imgData);
          const pdfWidth = pdf.internal.pageSize.getWidth();
          const pdfHeight = (imgProps.height * pdfWidth) / imgProps.width;

          // Calculate the image height and position considering margins
          const availableHeight =
            pdf.internal.pageSize.getHeight() - margin * 2;
          const scaledHeight = Math.min(pdfHeight, availableHeight);
          const yPosition = margin;

          // Add the image to the PDF with margins
          pdf.addImage(imgData, "PNG", 0, yPosition, pdfWidth, scaledHeight);

          // Add a new page for the next segment, except the last one
          if ((currentPage + 1) * pageHeightPx < totalHeightPx) {
            pdf.addPage();
          }
          currentPage++;
        }

        // Clean up the DOM after rendering
        document.body.removeChild(container);

        // Add a new page for the next student, except the last one
        if (i < students.length - 1) {
          pdf.addPage();
        }
      }

      // Save the PDF for the current exam type
      pdf.save(
        `${batchFullDetailsData.batch_code}_${type}_admission_cards.pdf`
      );
    }
    setGenerating(false);
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
      setDecodeBatchCode(parseString(batchFullDetailsData.batch_code));
    }
  }, [batchFullDetailsData]);

  useEffect(() => {
    if (decodeBatchCode) {
      setLevel_ordinal(numberToOrdinalWord(decodeBatchCode.level));
      setSem_ordinal(numberToOrdinalWord(decodeBatchCode.sem_no));
    }
  }, [decodeBatchCode]);

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
        decodeBatchCode={decodeBatchCode}
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

export default Page;
