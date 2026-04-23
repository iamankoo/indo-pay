import { Download, ServerCrash } from "lucide-react";

import { DashboardCharts } from "@/components/dashboard/dashboard-charts";
import { FraudFeed } from "@/components/dashboard/fraud-feed";
import { KpiCard } from "@/components/dashboard/kpi-card";
import { buttonVariants } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { getDashboardSnapshot } from "@/lib/dashboard-data";
import { cn } from "@/lib/utils";

function formatInr(value: number) {
  return new Intl.NumberFormat("en-IN", {
    style: "currency",
    currency: "INR",
    maximumFractionDigits: 0,
  }).format(value);
}

export default async function DashboardPage() {
  const snapshot = await getDashboardSnapshot();
  const { data, backend } = snapshot;

  if (!data) {
    return (
      <main className="space-y-6">
        <Card className="space-y-4 border-red-400/20 bg-red-500/5">
          <div className="flex items-center gap-3">
            <div className="rounded-2xl bg-red-500/10 p-3 text-red-200">
              <ServerCrash className="h-5 w-5" />
            </div>
            <div>
              <h2 className="text-xl font-semibold">Analytics backend unavailable</h2>
              <p className="text-sm text-muted-foreground">
                The dashboard is intentionally withholding fake fallback metrics.
              </p>
            </div>
          </div>
          <div className="grid gap-3 md:grid-cols-2">
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">Backend URL</p>
              <p className="mt-2 text-sm font-medium">{backend.url}</p>
            </Card>
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">Last error</p>
              <p className="mt-2 text-sm font-medium">{snapshot.error ?? "Unknown error"}</p>
            </Card>
          </div>
        </Card>
      </main>
    );
  }

  return (
    <main className="space-y-6">
      <section className="flex flex-col gap-4 rounded-[28px] border border-border/70 bg-card/80 p-6 shadow-[0_24px_80px_rgba(5,10,25,0.24)] backdrop-blur-xl lg:flex-row lg:items-center lg:justify-between">
        <div>
          <p className="text-sm text-muted-foreground">Beta control status</p>
          <h2 className="mt-2 text-2xl font-semibold tracking-tight">
            {backend.ok ? "Backend live and responding" : "Backend needs attention"}
          </h2>
          <p className="mt-2 text-sm text-muted-foreground">
            {backend.service} checked at{" "}
            {new Date(backend.checkedAt).toLocaleString("en-IN", {
              dateStyle: "medium",
              timeStyle: "short",
            })}
          </p>
        </div>
        <div className="flex flex-wrap gap-3">
          <a
            className={cn(buttonVariants({ variant: "secondary" }))}
            href="/api/export/dashboard"
          >
            <Download className="mr-2 h-4 w-4" />
            Export CSV
          </a>
          <div className="rounded-2xl border border-border/70 bg-black/10 px-4 py-3 text-sm text-muted-foreground">
            Source: {backend.url}
          </div>
        </div>
      </section>

      <section className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
        <KpiCard
          label="GMV today"
          value={formatInr(data.gmvToday)}
          hint="Core payment throughput across QR, recharge, and merchant collection."
        />
        <KpiCard
          label="Wallet liability"
          value={formatInr(data.walletLiability)}
          hint={`${data.rewardBurnPercent}% burn efficiency with expiry and redemption controls.`}
        />
        <KpiCard
          label="Success rate"
          value={`${data.transactionSuccessRate}%`}
          hint={`${data.bankTransferVolume.toLocaleString("en-IN")} INR processed on IMPS, NEFT, and RTGS.`}
        />
        <KpiCard
          label="Imphal beta"
          value={`${data.imphalBetaCohort.activeUsers} users`}
          hint={`${data.imphalBetaCohort.merchants} merchants driving ${formatInr(data.imphalBetaCohort.gmv)} GMV.`}
        />
      </section>

      <DashboardCharts data={data} />

      <section className="grid gap-6 lg:grid-cols-[1.2fr_0.8fr]">
        <Card className="space-y-6">
          <div>
            <h2 className="text-xl font-semibold">Retention and growth stack</h2>
            <p className="text-sm text-muted-foreground">
              Daily active users, weekly active users, cashback economics, and recharge mix.
            </p>
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">DAU / WAU</p>
              <p className="mt-3 text-3xl font-semibold">
                {data.dau} / {data.wau}
              </p>
            </Card>
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">Recharge volume</p>
              <p className="mt-3 text-3xl font-semibold">
                {formatInr(data.rechargeVolume)}
              </p>
            </Card>
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">Merchant volume</p>
              <p className="mt-3 text-3xl font-semibold">
                {formatInr(data.merchantVolume)}
              </p>
            </Card>
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">Cashback issued / expired</p>
              <p className="mt-3 text-3xl font-semibold">
                {formatInr(data.cashbackIssuedToday)} / {formatInr(data.cashbackExpiredToday)}
              </p>
            </Card>
          </div>
        </Card>
        <FraudFeed alerts={data.fraudAlerts} />
      </section>

      <section className="grid gap-6 lg:grid-cols-[1.15fr_0.85fr]">
        <Card className="space-y-5">
          <div>
            <h2 className="text-xl font-semibold">Merchant growth table</h2>
            <p className="text-sm text-muted-foreground">
              Revenue concentration across the operators driving today&apos;s beta cohort.
            </p>
          </div>
          <div className="overflow-hidden rounded-3xl border border-border/70">
            <table className="w-full border-collapse text-sm">
              <thead className="bg-white/5 text-left text-muted-foreground">
                <tr>
                  <th className="px-4 py-3 font-medium">Merchant</th>
                  <th className="px-4 py-3 font-medium">Orders</th>
                  <th className="px-4 py-3 font-medium">Volume</th>
                </tr>
              </thead>
              <tbody>
                {data.topMerchants.map((merchant) => (
                  <tr key={merchant.merchantId ?? "unassigned"} className="border-t border-border/60">
                    <td className="px-4 py-3 font-medium">{merchant.merchantId ?? "Unassigned"}</td>
                    <td className="px-4 py-3 text-muted-foreground">{merchant.orders}</td>
                    <td className="px-4 py-3">{formatInr(merchant.volume)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </Card>

        <Card className="space-y-5">
          <div>
            <h2 className="text-xl font-semibold">Imphal beta cohort</h2>
            <p className="text-sm text-muted-foreground">
              Readiness snapshot for the first 10 to 20 launch users and merchants.
            </p>
          </div>
          <div className="grid gap-4">
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">Active users</p>
              <p className="mt-2 text-3xl font-semibold">{data.imphalBetaCohort.activeUsers}</p>
            </Card>
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">Merchants live</p>
              <p className="mt-2 text-3xl font-semibold">{data.imphalBetaCohort.merchants}</p>
            </Card>
            <Card className="bg-black/10">
              <p className="text-sm text-muted-foreground">GMV</p>
              <p className="mt-2 text-3xl font-semibold">
                {formatInr(data.imphalBetaCohort.gmv)}
              </p>
            </Card>
          </div>
        </Card>
      </section>
    </main>
  );
}
