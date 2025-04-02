"use client";

import * as React from "react";
import * as ProgressPrimitive from "@radix-ui/react-progress";

import { cn } from "@/lib/utils";

const Progress = React.forwardRef(
  ({ className, value, barColor, content, ...props }, ref) => {
    return (
      <ProgressPrimitive.Root
        ref={ref}
        className={cn(
          `relative text-xs h-2 w-full overflow-hidden rounded-full before:content-[attr(data-content)] 
         before:w-full before:h-full before:z-30 before:absolute before:left-0 before:top-0 before:flex before:justify-center before:items-center before:text-white ${
           barColor ? barColor : "border border-black before:text-black"
         } bg-opacity-20`,
          className
        )}
        data-content={content}
        {...props}
      >
        <ProgressPrimitive.Indicator
          className={`h-full w-full flex-1 ${
            barColor ? barColor : "bg-primary"
          } transition-all`}
          style={{ transform: `translateX(-${100 - (value || 0)}%)` }}
        />
      </ProgressPrimitive.Root>
    );
  }
);
Progress.displayName = ProgressPrimitive.Root.displayName;

export { Progress };
