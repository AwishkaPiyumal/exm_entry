import React, { useEffect, useState } from "react";
import ReactQuill from "react-quill";
import "react-quill/dist/quill.snow.css";

const RichTextEditor = ({ element, text, setFormData }) => {
  return (
    <ReactQuill
      theme="snow"
      value={text}
      onChange={(e) => setFormData((cur) => ({ ...cur, [element]: e }))}
      style={{ height: "150px", marginBottom: "50px" }}
      className="font-serif mb-3"
    />
  );
};

export default RichTextEditor;
