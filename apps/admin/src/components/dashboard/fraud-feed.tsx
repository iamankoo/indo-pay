import { AlertTriangle } from "lucide-react";

import { Badge } from "@/components/ui/badge";
import { Card } from "@/components/ui/card";
import type { AnalyticsDashboard } from "@/lib/dashboard-data";

export function FraudFeed({
  alerts,
}: {
  alerts: AnalyticsDashboard["fraudAlerts"];
}) {
  if (alerts.length === 0) {
    return (
      <Card className="space-y-4">
        <div className="flex items-center justify-between">
          <div>
            <h2 className="text-xl font-semibold">Fraud alerts</h2>
            <p className="text-sm text-muted-foreground">
              Queue-ready review feed for operations and risk.
            </p>
          </div>
          <Badge>Clear</Badge>
        </div>
        <div className="rounded-2xl border border-border/70 bg-black/10 p-4 text-sm text-muted-foreground">
          No high-risk events are waiting for review right now.
        </div>
      </Card>
    );
  }

  return (
    <Card className="space-y-4">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-xl font-semibold">Fraud alerts</h2>
          <p className="text-sm text-muted-foreground">
            Queue-ready review feed for operations and risk.
          </p>
        </div>
        <Badge>Priority lane</Badge>
      </div>
      <div className="space-y-3">
        {alerts.map((alert) => (
          <div
            key={alert.id}
            className="rounded-2xl border border-border/70 bg-black/10 p-4"
          >
            <div className="flex items-start gap-3">
              <div className="rounded-2xl bg-secondary/10 p-2 text-secondary">
                <AlertTriangle className="h-4 w-4" />
              </div>
              <div className="flex-1">
                <p className="font-medium">{alert.reason}</p>
                <p className="text-sm text-muted-foreground">
                  Risk score {alert.riskScore}
                </p>
              </div>
              <Badge
                className={
                  alert.riskScore >= 85
                    ? "bg-red-500/10 text-red-200"
                    : "bg-white/10 text-foreground"
                }
              >
                {alert.riskScore >= 85 ? "Escalate" : "Review"}
              </Badge>
            </div>
            <p className="mt-3 text-xs text-muted-foreground">
              {new Date(alert.createdAt).toLocaleString("en-IN", {
                dateStyle: "medium",
                timeStyle: "short",
              })}
            </p>
          </div>
        ))}
      </div>
    </Card>
  );
}
