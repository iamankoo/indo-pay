import * as React from "react";

import { cn } from "@/lib/utils";

export function Card({
  className,
  ...props
}: React.HTMLAttributes<HTMLDivElement>) {
  return (
    <div
      className={cn(
        "rounded-[28px] border border-border/70 bg-card/90 p-6 shadow-[0_24px_80px_rgba(5,10,25,0.24)] backdrop-blur-xl",
        className
      )}
      {...props}
    />
  );
}
