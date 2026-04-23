import { ArrowUpRight } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";

export function KpiCard({
  label,
  value,
  hint,
}: {
  label: string;
  value: string;
  hint: string;
}) {
  return (
    <Card className="space-y-4 bg-card/95">
      <div className="flex items-center justify-between">
        <p className="text-sm text-muted-foreground">{label}</p>
        <Badge className="gap-1">
          <ArrowUpRight className="h-3.5 w-3.5" />
          Live
        </Badge>
      </div>
      <div>
        <p className="text-3xl font-semibold tracking-tight">{value}</p>
        <p className="mt-2 text-sm text-muted-foreground">{hint}</p>
      </div>
    </Card>
  );
}
