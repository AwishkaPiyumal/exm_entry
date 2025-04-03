import { useState, useRef } from "react";
import { Switch } from "./ui/switch";
import { Popover, PopoverContent, PopoverTrigger } from "./ui/popover";
import { Textarea } from "./ui/textarea";
import { Button } from "./ui/button";

const EligibilityCell = ({ row, onEligibilityChanged }) => {
  const [remark, setRemark] = useState("");

  return (
    <Popover>
      <PopoverTrigger className="trigger flex justify-center w-full">
        <Switch
          id={row.original.s_id}
          onClick={(e) => {
            e.preventDefault();
            e.target.parentElement.click();
          }}
          checked={row.original.eligibility == "true"}
        />
      </PopoverTrigger>
      <PopoverContent className="w-64 h-40 flex flex-col gap-2 items-start">
        <p className="font-semibold flex justify-between text-sm w-full">
          <span>Enter Remark</span>
          <span>{row.original.user_name}</span>
        </p>
        <Textarea
          onChange={(e) => setRemark(e.target.value)}
          onBlur={() => setRemark("")}
          value={remark}
        />
        <Button
          className="self-end changeEli"
          onMouseDown={() => {
            if (remark) {
              const val = row.original.eligibility == "true";
              onEligibilityChanged(row.original.s_id, !val + "", remark);
            }
          }}
          disabled={!remark}
        >
          Change Eligibility
        </Button>
      </PopoverContent>
    </Popover>
  );
};

export default EligibilityCell;
