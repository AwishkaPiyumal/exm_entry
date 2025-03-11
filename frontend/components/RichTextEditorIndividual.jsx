"use client";

import React, { useEffect, useState } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";

const RichTextEditorIndividual = ({
  element,
  text,
  setFormData,
  height,
  width,
  setCurrentEditor,
  currentEditor,
  unique,
}) => {
  return (
    <ReactQuill
      theme="snow"
      value={text}
      onFocus={() => setCurrentEditor(unique)}
      onChange={(value) => {
        if (currentEditor === unique) {
          setFormData((cur) => ({
            ...cur,
            [element]: value,
          }));
        }
      }}
      style={{ height, width, marginBottom: "50px" }}
      className="font-serif mb-3"
    />
  );
};

export default RichTextEditorIndividual;
