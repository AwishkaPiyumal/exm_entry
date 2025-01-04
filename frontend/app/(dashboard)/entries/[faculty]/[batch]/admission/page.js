"use client";
import AdmissionCardTemplate from "@/components/AdmissionCardTemplate";
import { createOrUpdateAdmission } from "@/utils/apiRequests/entry.api";
import { getModifiedDate } from "@/utils/functions";
import { useMutation } from "@tanstack/react-query";
import { useSearchParams } from "next/navigation";
import { useState } from "react";
import { Button } from "react-day-picker";
import { toast } from "sonner";

const Admission = () => {
  const searchParams = useSearchParams();
  const batch_id = searchParams.get("batch_id");
  const [formData, setFormData] = useState({
    batch_id,
    generated_date: getModifiedDate(new Date()),
    subjects: [],
    date: [{ year: new Date().getFullYear(), months: [new Date().getMonth()] }],
    description:
      "<p>Candidates are expected to produce this admission card to the  Supervisor/Invigilator/Examiner at the Examination Hall. This form &nbsp; &nbsp; &nbsp; should be filled and signed by the candidates in the presence of the Supervisor/Invigilator/Examiner every time a paper test is taken. The &nbsp; Supervisor/Invigilator/Examiner is expected to authenticate the signature of the candidate by placing his/her initials in the appropriate column. Students are requested to hand over the admission card to the Supervisor on the last day of the paper.</p>",
    instructions:
      "<p><strong><u>Instructions</u></strong></p><ol><li>No candidate shall be admitted to the Examination hall without this card.</li><li>If any candidate loses this admission card, he/she shall obtain a duplicate Admission Card on payment of Rs.150/-</li><li>Every candidate shall produce his/her Identity Card at every paper/Practical Examination he/she sits for.</li><li>Any unauthorized documents, notes &amp; bags should not be taken into the Examinations.</li><li>When unable to be present for any part of the Examination, it should be notified to me&nbsp;<strong><u>immediately in writing</u></strong>&nbsp;. No appeals will be considered later without this timely notification.</li></ol>",
  });

  const { status, mutate } = useMutation({
    mutationFn: createOrUpdateAdmission,
    onSuccess: (res) => {
      console.log(res);
      toast(res.message);
    },
    onError: (err) => {
      console.log(err);
      toast("Operation failed");
    },
  });

  const onGenerate = () => {
    mutate(formData);
  };

  return (
    <>
      <AdmissionCardTemplate
        batch_id={batch_id}
        setFormData={setFormData}
        formData={formData}
      />{" "}
      <div className="flex justify-center mt-8">
        <Button onClick={onGenerate}>Generate</Button>
      </div>
    </>
  );
};

export default Admission;
