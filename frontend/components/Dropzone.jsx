import { useState, useCallback } from "react";
import { useDropzone } from "react-dropzone";
import { FaDownload, FaFileCsv, FaFileExcel } from "react-icons/fa6";
import { FaTimesCircle } from "react-icons/fa";

const Dropzone = ({ file, setFile }) => {
  const [error, setError] = useState(null); // Store any error message
  const [dragged, setDragged] = useState(false); // State for visual feedback
  const [fileType, setFileType] = useState(null);

  const onDrop = useCallback((acceptedFiles, rejectedFiles) => {
    setError(null); // Clear previous error
    setDragged(false); // Reset drag state

    // Check for rejected files or multiple files
    if (rejectedFiles.length > 0) {
      setError("Invalid file type. Only CSV and Excel are allowed.");
      return;
    }
    if (acceptedFiles.length > 1) {
      setError("Please drop only one file at a time.");
      return;
    }

    // Store the accepted file
    const droppedFile = acceptedFiles[0];
    setFile(droppedFile);
    setFileType(droppedFile.type);
  }, []);

  const { getRootProps, getInputProps, isDragActive } = useDropzone({
    onDrop,
    accept: {
      "text/csv": [".csv"],
      "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet": [
        ".xlsx",
      ],
      "application/vnd.ms-excel": [".xls"],
    },
    maxFiles: 1,
  });

  // Remove the file
  const handleRemoveFile = () => {
    setFile(null);
    setError(null);
  };

  return (
    <div {...getRootProps({ className: "dropzone" })}>
      <input className="input-zone" {...getInputProps()} />
      <div
        onDragEnter={() => setDragged(true)}
        onDragLeave={() => setDragged(false)}
        onDragOver={(e) => e.preventDefault()} // Allow drop
        className={`transition-all duration-300 ${
          dragged
            ? "bg-blue-100 border-blue-500 text-blue-500"
            : "bg-gray-100 border-gray-400 text-gray-700"
        } border-2 font-semibold flex flex-col justify-center items-center border-dashed rounded-lg h-40 p-8`}
      >
        {!file && !error && (
          <>
            <FaDownload
              className={`transition-all duration-300 ${
                dragged ? "text-blue-500" : "text-gray-400"
              } text-6xl mx-auto mb-3`}
            />
            <p className="dropzone-content text-center">
              Drag &amp; drop a CSV or Excel file here, or click to select a
              file
            </p>
          </>
        )}
        {file && (
          <div className="text-center">
            {fileType == "text/csv" ? (
              <FaFileCsv className="text-5xl mx-auto mb-4" />
            ) : (
              <FaFileExcel className="text-5xl mx-auto mb-4" />
            )}
            <p className="text-sm font-semibold text-gray-800">{file.name}</p>
            <button
              className="mt-2 bg-red-500 hover:bg-red-600 text-white font-semibold py-1 px-4 rounded-lg flex items-center gap-2 mx-auto"
              onClick={handleRemoveFile}
            >
              <FaTimesCircle /> Cancel
            </button>
          </div>
        )}
        {error && (
          <p className="mt-3 text-red-500 font-semibold text-sm">{error}</p>
        )}
      </div>
    </div>
  );
};

export default Dropzone;
