import { NextResponse } from "next/server";

import { readAdminSession } from "@/lib/auth";
import { buildDashboardCsv, getDashboardSnapshot } from "@/lib/dashboard-data";

export async function GET() {
  const session = await readAdminSession();
  if (!session) {
    return NextResponse.json({ message: "Unauthorized" }, { status: 401 });
  }

  const snapshot = await getDashboardSnapshot();
  if (!snapshot.data) {
    return NextResponse.json(
      { message: snapshot.error ?? "Dashboard export unavailable" },
      { status: 503 },
    );
  }

  const csv = buildDashboardCsv(snapshot);
  const timestamp = snapshot.fetchedAt.replaceAll(":", "-");

  return new NextResponse(csv, {
    status: 200,
    headers: {
      "Content-Type": "text/csv; charset=utf-8",
      "Content-Disposition": `attachment; filename="indo-pay-dashboard-${timestamp}.csv"`,
      "Cache-Control": "no-store",
    },
  });
}
