"use client";

import { Area, AreaChart, Bar, BarChart, CartesianGrid, ResponsiveContainer, Tooltip, XAxis, YAxis } from "recharts";

import { Card } from "@/components/ui/card";
import type { AnalyticsDashboard } from "@/lib/dashboard-data";

export function DashboardCharts({
  data,
}: {
  data: AnalyticsDashboard;
}) {
  return (
    <div className="grid gap-6 lg:grid-cols-[1.6fr_1fr]">
      <Card className="space-y-6">
        <div>
          <h2 className="text-xl font-semibold">City adoption momentum</h2>
          <p className="text-sm text-muted-foreground">
            Merchant-led GMV expansion across launch cities.
          </p>
        </div>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <AreaChart data={data.cityWiseAdoption}>
              <defs>
                <linearGradient id="gmv" x1="0" y1="0" x2="0" y2="1">
                  <stop offset="0%" stopColor="#0b4dff" stopOpacity={0.82} />
                  <stop offset="100%" stopColor="#0b4dff" stopOpacity={0.08} />
                </linearGradient>
              </defs>
              <CartesianGrid stroke="rgba(143,162,196,0.12)" vertical={false} />
              <XAxis dataKey="city" stroke="#8fa2c4" />
              <YAxis stroke="#8fa2c4" />
              <Tooltip />
              <Area
                type="monotone"
                dataKey="gmv"
                stroke="#0b4dff"
                fill="url(#gmv)"
                strokeWidth={3}
              />
            </AreaChart>
          </ResponsiveContainer>
        </div>
      </Card>
      <Card className="space-y-6">
        <div>
          <h2 className="text-xl font-semibold">Top merchants</h2>
          <p className="text-sm text-muted-foreground">
            Volume concentration across the highest-performing partners.
          </p>
        </div>
        <div className="h-80">
          <ResponsiveContainer width="100%" height="100%">
            <BarChart data={data.topMerchants}>
              <CartesianGrid stroke="rgba(143,162,196,0.12)" vertical={false} />
              <XAxis dataKey="merchantId" stroke="#8fa2c4" />
              <YAxis stroke="#8fa2c4" />
              <Tooltip />
              <Bar dataKey="volume" fill="#ff9b2f" radius={[12, 12, 0, 0]} />
            </BarChart>
          </ResponsiveContainer>
        </div>
      </Card>
    </div>
  );
}
