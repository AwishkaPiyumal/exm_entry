"use client";

import { Progress } from "@/components/ui/progress";
import { useEffect, useState } from "react";

const BatchProgress = ({ task }) => {
  const [progress, setProgress] = useState(1);
  const [content, setContent] = useState("");
  const [barColor, setBarColor] = useState("");

  useEffect(() => {
    let newVal = 0;
    switch (task) {
      case "stu":
        newVal = 17;
        setBarColor("bg-blue-500");
        setContent("Students applying");
        break;
      case "lec":
        newVal = 35;
        setBarColor("bg-green-500");
        setContent("lecturers reviewing");
        break;
      case "hod":
        newVal = 51;
        setBarColor("bg-yellow-500");
        setContent("Under HOD approval");
        break;
      case "dean":
        newVal = 68;
        setBarColor("bg-orange-500");
        setContent("Under Dean approval");
        break;
      case "adm":
        newVal = 84;
        setBarColor("bg-rose-500");
        setContent("Processing admission/attendance");
        break;
      case "done":
        newVal = 100;
        setBarColor("bg-red-600");
        setContent("Done");
        break;
      default:
        newVal = 0;
        setBarColor("");
        setContent("Application not opened yet!");
        break;
    }

    const timer = setTimeout(() => setProgress(newVal), 500);
    return () => clearTimeout(timer);
  }, [task]);

  return (
    <Progress
      value={progress}
      barColor={barColor}
      content={content}
      className="w-[100%] h-6"
    />
  );
};

export default BatchProgress;
