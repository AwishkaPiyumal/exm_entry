import { Checkbox } from "@/components/ui/checkbox";
import { Label } from "@/components/ui/label";
import { TableCell, TableRow } from "@/components/ui/table";
import { useEffect, useState } from "react";
import { GiCancel } from "react-icons/gi";

const StudentRow = ({
  row,
  curriculumsOfBatchData,
  setSelectedSubjects,
  selectedSubjects,
  ind,
  setRows,
}) => {
  const [type, setType] = useState("");

  return (
    <TableRow className="flex">
      <TableCell className="w-[150px]">
        {selectedSubjects[row]?.userName}
      </TableCell>{" "}
      <TableCell className="w-8 text-center">
        <GiCancel
          className="text-xl text-red-500 hover:cursor-pointer hover:text-red-700"
          onClick={() => {
            setRows((cur) => {
              let curRows = [...cur];
              curRows.splice(ind, 1, null);

              return curRows;
            });
            setSelectedSubjects((cur) => {
              let curObj = { ...cur };
              let newSubs = curObj[row].newSubjects.filter(
                (obj) => obj.modifier != ind
              );
              curObj[row].newSubjects = newSubs;
              return curObj;
            });
          }}
        />
      </TableCell>
      {type ? (
        <TableCell className="w-24 flex justify-center">
          <p className="flex items-center space-x-1">
            {type == "M" ? "Medical" : "Resit"}
          </p>
        </TableCell>
      ) : (
        <TableCell className="w-24 flex justify-between">
          <p className="flex items-center space-x-1">
            <input
              type="radio"
              value="M"
              id={`type:M:${row}`}
              checked={type == "M"}
              name={`type:${row}`}
              onChange={(e) => setType(e.target.value)}
              className="h-4 w-4 shadow focus:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 accent-black"
            />
            <Label htmlFor="M" className="cursor-pointer">
              M
            </Label>
          </p>
          <p className="flex items-center space-x-1">
            <input
              type="radio"
              value="R"
              id={`type:R:${row}`}
              checked={type == "R"}
              name={`type:${row}`}
              onChange={(e) => setType(e.target.value)}
              className="h-4 w-4 shadow focus:outline-none focus-visible:ring-1 focus-visible:ring-ring disabled:cursor-not-allowed disabled:opacity-50 accent-black"
            />
            <Label htmlFor="R" className="cursor-pointer">
              R
            </Label>
          </p>
        </TableCell>
      )}
      {type &&
        curriculumsOfBatchData &&
        curriculumsOfBatchData.map((obj) =>
          selectedSubjects[row].existingSubjects.includes(obj.sub_id) ? (
            <TableCell className="w-16 text-center" key={ind + obj.sub_id}>
              <Checkbox key={obj.sub_id} checked={true} disabled={true} />
            </TableCell>
          ) : (
            <TableCell className="w-16 text-center" key={ind + obj.sub_id}>
              <Checkbox
                key={obj.sub_id}
                id={`${obj.sub_id}:${type}`}
                onCheckedChange={(e) => {
                  setSelectedSubjects((cur) => {
                    const updatedSubjects = { ...cur };

                    // Check if the subject already exists in newSubjects
                    const subjectExists = updatedSubjects[row].newSubjects.some(
                      (sub_obj) => sub_obj.sub_id === obj.sub_id
                    );

                    if (e) {
                      // If checked, add or update the subject
                      if (!subjectExists) {
                        updatedSubjects[row].newSubjects.push({
                          sub_id: obj.sub_id,
                          type,
                          modifier: ind,
                        });
                      } else {
                        updatedSubjects[row].newSubjects = updatedSubjects[
                          row
                        ].newSubjects.map((sub_obj) =>
                          sub_obj.sub_id === obj.sub_id
                            ? { ...sub_obj, type, modifier: ind }
                            : sub_obj
                        );
                      }
                    } else {
                      // If unchecked, remove the subject
                      updatedSubjects[row].newSubjects = updatedSubjects[
                        row
                      ].newSubjects.filter(
                        (sub_obj) => sub_obj.sub_id !== obj.sub_id
                      );
                    }

                    return updatedSubjects;
                  });
                }}
                checked={selectedSubjects[row]?.newSubjects.some(
                  (object) =>
                    object.sub_id === obj.sub_id && object.type == type
                )}
              />
            </TableCell>
          )
        )}
    </TableRow>
  );
};

export default StudentRow;
