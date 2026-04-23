export interface AnalyticsDashboard {
  gmvToday: number;
  dau: number;
  wau: number;
  rechargeVolume: number;
  merchantVolume: number;
  cashbackIssuedToday: number;
  cashbackRedeemedToday: number;
  cashbackExpiredToday: number;
  walletLiability: number;
  rewardBurnPercent: number;
  transactionSuccessRate: number;
  bankTransferVolume: number;
  topMerchants: Array<{
    merchantId: string | null;
    volume: number;
    orders: number;
  }>;
  fraudAlerts: Array<{
    id: string;
    reason: string;
    riskScore: number;
    createdAt: string;
  }>;
  retentionCohorts: Array<{
    cohort: string;
    retainedUsers: number;
    retainedPercent: number;
  }>;
  cityWiseAdoption: Array<{
    city: string;
    merchants: number;
    gmv: number;
  }>;
  imphalBetaCohort: {
    merchants: number;
    activeUsers: number;
    gmv: number;
  };
}

export interface DashboardHealth {
  ok: boolean;
  status: string;
  checkedAt: string;
  service: string;
  url: string;
}

export interface DashboardSnapshot {
  data: AnalyticsDashboard | null;
  backend: DashboardHealth;
  fetchedAt: string;
  error: string | null;
  isLive: boolean;
}

interface BackendHealthResponse {
  status?: string;
  service?: string;
  timestamp?: string;
}

function normalizeBaseUrl() {
  const configured = process.env.INDO_PAY_API_URL ?? "http://127.0.0.1:4000/api/v1";
  return configured.endsWith("/") ? configured.slice(0, -1) : configured;
}

async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url, {
    cache: "no-store",
    headers: {
      Accept: "application/json",
    },
  });

  if (!response.ok) {
    throw new Error(`Backend request failed with status ${response.status}.`);
  }

  return (await response.json()) as T;
}

export async function getDashboardSnapshot(): Promise<DashboardSnapshot> {
  const baseUrl = normalizeBaseUrl();
  const fetchedAt = new Date().toISOString();

  const [dashboardResult, healthResult] = await Promise.allSettled([
    fetchJson<AnalyticsDashboard>(`${baseUrl}/analytics/dashboard`),
    fetchJson<BackendHealthResponse>(`${baseUrl}/health`),
  ]);

  const backend: DashboardHealth =
    healthResult.status === "fulfilled"
      ? {
          ok: true,
          status: healthResult.value.status ?? "ok",
          checkedAt: healthResult.value.timestamp ?? fetchedAt,
          service: healthResult.value.service ?? "indo-pay-backend",
          url: baseUrl,
        }
      : {
          ok: false,
          status: "unreachable",
          checkedAt: fetchedAt,
          service: "indo-pay-backend",
          url: baseUrl,
        };

  if (dashboardResult.status === "fulfilled") {
    return {
      data: dashboardResult.value,
      backend,
      fetchedAt,
      error: null,
      isLive: true,
    };
  }

  return {
    data: null,
    backend,
    fetchedAt,
    error: dashboardResult.reason instanceof Error
      ? dashboardResult.reason.message
      : "Unable to reach analytics backend.",
    isLive: false,
  };
}

export function buildDashboardCsv(snapshot: DashboardSnapshot) {
  if (!snapshot.data) {
    throw new Error("Dashboard export is unavailable until the analytics API responds.");
  }

  const { data } = snapshot;
  const lines: string[][] = [
    ["metric", "value"],
    ["gmvToday", String(data.gmvToday)],
    ["dau", String(data.dau)],
    ["wau", String(data.wau)],
    ["rechargeVolume", String(data.rechargeVolume)],
    ["merchantVolume", String(data.merchantVolume)],
    ["cashbackIssuedToday", String(data.cashbackIssuedToday)],
    ["cashbackRedeemedToday", String(data.cashbackRedeemedToday)],
    ["cashbackExpiredToday", String(data.cashbackExpiredToday)],
    ["walletLiability", String(data.walletLiability)],
    ["rewardBurnPercent", String(data.rewardBurnPercent)],
    ["transactionSuccessRate", String(data.transactionSuccessRate)],
    ["bankTransferVolume", String(data.bankTransferVolume)],
    ["imphalMerchants", String(data.imphalBetaCohort.merchants)],
    ["imphalActiveUsers", String(data.imphalBetaCohort.activeUsers)],
    ["imphalGmv", String(data.imphalBetaCohort.gmv)],
    [],
    ["city", "merchants", "gmv"],
    ...data.cityWiseAdoption.map((city) => [
      city.city,
      String(city.merchants),
      String(city.gmv),
    ]),
    [],
    ["merchantId", "orders", "volume"],
    ...data.topMerchants.map((merchant) => [
      merchant.merchantId ?? "unassigned",
      String(merchant.orders),
      String(merchant.volume),
    ]),
  ];

  return lines.map((columns) => columns.map(escapeCsvValue).join(",")).join("\n");
}

function escapeCsvValue(value: string) {
  if (/[",\n]/.test(value)) {
    return `"${value.replaceAll("\"", "\"\"")}"`;
  }

  return value;
}
