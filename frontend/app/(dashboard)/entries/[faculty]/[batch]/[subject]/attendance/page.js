"use client";
import dynamic from "next/dynamic";

const AdmissionCardTemplate = dynamic(
  () => import("@/components/AttendanceSheetTemplate"),
  {
    ssr: false,
  }
);
import { Button } from "@/components/ui/button";
import { getBatchFullDetails } from "@/utils/apiRequests/batch.api";
import {
  getAppliedStudentsForSubject,
  getCurriculumBybatchId,
} from "@/utils/apiRequests/curriculum.api";
import {
  createOrUpdateAttendance,
  getEligibleStudentsBySub,
  getLatestAttendanceTemplate,
} from "@/utils/apiRequests/entry.api";
import {
  numberToOrdinalWord,
  parseString,
  sortByExamType,
} from "@/utils/functions";
import { useMutation, useQuery } from "@tanstack/react-query";
import { useSearchParams } from "next/navigation";
import { useCallback, useEffect, useState } from "react";
import { toast } from "sonner";
import jsPDF from "jspdf";
import html2canvas from "html2canvas";
import { createRoot } from "react-dom/client";
import AttendanceSheetTemplate from "@/components/AttendanceSheetTemplate";
import AttendanceSheet from "@/components/AttendanceSheet";

function divideStudents(totalStudents, noOfGroups) {
  const groupSize = Math.ceil(totalStudents / noOfGroups);
  return groupSize;
}

const Page = () => {
  const searchParams = useSearchParams();
  const batch_id = searchParams.get("batch_id");
  const sub_id = searchParams.get("sub_id");
  const sub_name = searchParams.get("sub_name");
  const sub_code = searchParams.get("sub_code");

  const [level_ordinal, setLevel_ordinal] = useState("");
  const [sem_ordinal, setSem_ordinal] = useState("");
  const [decodeBatchCode, setDecodeBatchCode] = useState({});

  const [generating, setGenerating] = useState(false);
  const [groupsCount, setGroupsCount] = useState(1);
  const [avgStuCountPerGroup, setAvgStuCountPerGroup] = useState(0);
  const [finalNameList, setFinalNameList] = useState({});
  const [currentEditor, setCurrentEditor] = useState(null);
  const [formData, setFormData] = useState({
    batch_id,
    date: [{ year: new Date().getFullYear(), months: [new Date().getMonth()] }],
    description:
      '<p>Supervisors are kindly requested to mark absentees clearly "ABSENT" and "✔" those Present. One copy is to be returned under separate cover to the Deputy Registrar and one to be enclosed in the relevant packet of answer script, when answer scripts separately for each of a paper it is necessary to enclose a copy each of the attendance list in each packet.</p>',
  });

  const onGroupsCountBlured = (e) => {
    let value = +e.target.value;
    if (value < +e.target.min) {
      value = +e.target.min;
    } else if (value > +e.target.max) {
      value = +e.target.max;
    }

    setGroupsCount(value);
    e.target.value = value;
  };

  const generateAttendanceSheetPDFs = async () => {
    if (typeof document === "undefined") {
      console.error("This function can only run in a browser environment.");
      return;
    }

    const margin = 5; // Top and bottom margin in mm

    const pdf = new jsPDF("p", "mm", "a4");
    setGenerating(true);

    for (const [grpNo, grpArr] of Object.entries(finalNameList)) {
      for (let pageInd = 0; pageInd < grpArr.length; pageInd++) {
        const pageArr = grpArr[pageInd];

        const container = document.createElement("div");
        container.style.width = "210mm"; // A4 width
        container.style.padding = "20px";
        container.style.backgroundColor = "#fff";
        container.id = `AttendanceSheet-G${grpNo}-P${pageInd + 1}`;
        document.body.appendChild(container);

        const root = createRoot(container);
        const renderComplete = new Promise((resolve) => {
          root.render(
            <AttendanceSheet
              level_ordinal={level_ordinal}
              batchFullDetailsData={batchFullDetailsData}
              decodeBatchCode={decodeBatchCode}
              formData={formData}
              sem_ordinal={sem_ordinal}
              onRenderComplete={resolve}
              sub_name={sub_name}
              sub_code={sub_code}
              pageArr={pageArr}
              pageNo={pageInd + 1}
              groupNo={grpNo}
              totalPages={grpArr.length}
              totalGroups={Object.keys(finalNameList).length}
              totalStudents={eligibleStudentsForASubjectData.length}
              studentsInTheGroup={
                grpArr.flat().filter((obj) => typeof obj != "string").length
              }
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
          const availableHeight = pdf.internal.pageSize.getHeight() - margin;
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
        if (pageInd < grpArr.length - 1) {
          pdf.addPage();
        }
      }
      if (grpNo - 1 < Object.entries(finalNameList).length - 1) {
        pdf.addPage();
      }
    }

    pdf.save(
      `${batchFullDetailsData.batch_code}_${sub_code}_attendance_sheet.pdf`
    );

    setGenerating(false);
  };

  const { data: eligibleStudentsForASubjectData } = useQuery({
    queryFn: () => getEligibleStudentsBySub({ batch_id, sub_id }),
    queryKey: ["eligibleStudentsForASubject", batch_id, sub_id],
  });

  useEffect(() => {
    if (eligibleStudentsForASubjectData?.length) {
      let stuCountPerGroup = divideStudents(
        eligibleStudentsForASubjectData.length,
        groupsCount
      );
      setAvgStuCountPerGroup(stuCountPerGroup);
      let obj = {};
      let sortedArray = sortByExamType(eligibleStudentsForASubjectData);

      for (let i = 0; i < groupsCount; i++) {
        let grpArr = [];
        let pageArr = [];
        let pageArrInd = 0;
        let exam_type = "P";

        for (
          let j = i * stuCountPerGroup;
          j < (i + 1) * stuCountPerGroup && j < sortedArray.length;
          j++
        ) {
          if (sortedArray[j].exam_type != exam_type) {
            pageArr.push(sortedArray[j].exam_type);
            exam_type = sortedArray[j].exam_type;
            pageArrInd++;
          }
          pageArr.push(sortedArray[j]);

          if (
            pageArrInd == 79 ||
            j == (i + 1) * stuCountPerGroup - 1 ||
            j == sortedArray.length - 1
          ) {
            grpArr.push(pageArr);
            pageArr = [];
            pageArrInd = 0;
          } else {
            pageArrInd++;
          }

          if (
            j == (i + 1) * stuCountPerGroup - 1 ||
            j == sortedArray.length - 1
          ) {
            break;
          }
        }
        obj[i + 1] = grpArr;
      }
      setFinalNameList(obj);
    }
  }, [groupsCount, eligibleStudentsForASubjectData]);

  const { data: latestAttendanceTemplateData } = useQuery({
    queryFn: () => getLatestAttendanceTemplate(batch_id),
    queryKey: ["latestAttendanceTemplate", batch_id],
  });

  const {
    data: batchFullDetailsData,
    isLoading,
    error,
  } = useQuery({
    queryFn: () => getBatchFullDetails(batch_id),
    queryKey: ["batchFullDetails"],
  });

  const { status, mutate } = useMutation({
    mutationFn: createOrUpdateAttendance,
    onSuccess: (res) => {
      toast.success(res.message);
    },
    onError: (err) => {
      toast.error("Operation failed");
    },
  });

  const onGenerate = () => {
    mutate(formData);
    generateAttendanceSheetPDFs();
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
      <div className="w-[80%] mx-auto flex justify-center mb-4">
        <div>
          No of groups&nbsp;:&nbsp;
          <input
            type="number"
            min="1"
            max={eligibleStudentsForASubjectData?.length || 1}
            className="w-20 rounded-md border px-2 py-1 text-sm h-8"
            value={Object.keys(finalNameList).length}
            onChange={(e) => setGroupsCount(e.target.value)}
            onBlur={(e) => onGroupsCountBlured(e)}
          />
        </div>
      </div>
      {Object.entries(finalNameList).map(([grpNo, grpArr], _, entriesArr) =>
        grpArr.map((pageArr, pageInd, arr) => (
          <AttendanceSheetTemplate
            key={grpNo + "" + pageInd}
            batch_id={batch_id}
            setFormData={setFormData}
            formData={formData}
            setCurrentEditor={setCurrentEditor}
            currentEditor={currentEditor}
            batchFullDetailsData={batchFullDetailsData}
            latestAttendanceTemplateData={latestAttendanceTemplateData}
            level_ordinal={level_ordinal}
            sem_ordinal={sem_ordinal}
            decodeBatchCode={decodeBatchCode}
            sub_name={sub_name}
            sub_code={sub_code}
            pageArr={pageArr}
            pageNo={pageInd + 1}
            groupNo={grpNo}
            totalPages={arr.length}
            totalGroups={entriesArr.length}
            setFinalNameList={setFinalNameList}
            finalNameList={finalNameList}
            totalStudents={eligibleStudentsForASubjectData.length}
            studentsInTheGroup={
              grpArr.flat().filter((obj) => typeof obj != "string").length
            }
          />
        ))
      )}

      <div className="flex justify-center mt-8">
        <Button onClick={onGenerate}>Generate</Button>
      </div>
    </>
  );
};

export default Page;
