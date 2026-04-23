module.exports = [
"[externals]/next/dist/compiled/next-server/app-route-turbo.runtime.dev.js [external] (next/dist/compiled/next-server/app-route-turbo.runtime.dev.js, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/compiled/next-server/app-route-turbo.runtime.dev.js", () => require("next/dist/compiled/next-server/app-route-turbo.runtime.dev.js"));

module.exports = mod;
}),
"[externals]/next/dist/compiled/@opentelemetry/api [external] (next/dist/compiled/@opentelemetry/api, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/compiled/@opentelemetry/api", () => require("next/dist/compiled/@opentelemetry/api"));

module.exports = mod;
}),
"[externals]/next/dist/compiled/next-server/app-page-turbo.runtime.dev.js [external] (next/dist/compiled/next-server/app-page-turbo.runtime.dev.js, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/compiled/next-server/app-page-turbo.runtime.dev.js", () => require("next/dist/compiled/next-server/app-page-turbo.runtime.dev.js"));

module.exports = mod;
}),
"[externals]/next/dist/server/app-render/work-unit-async-storage.external.js [external] (next/dist/server/app-render/work-unit-async-storage.external.js, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/server/app-render/work-unit-async-storage.external.js", () => require("next/dist/server/app-render/work-unit-async-storage.external.js"));

module.exports = mod;
}),
"[externals]/next/dist/server/app-render/work-async-storage.external.js [external] (next/dist/server/app-render/work-async-storage.external.js, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/server/app-render/work-async-storage.external.js", () => require("next/dist/server/app-render/work-async-storage.external.js"));

module.exports = mod;
}),
"[externals]/next/dist/shared/lib/no-fallback-error.external.js [external] (next/dist/shared/lib/no-fallback-error.external.js, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/shared/lib/no-fallback-error.external.js", () => require("next/dist/shared/lib/no-fallback-error.external.js"));

module.exports = mod;
}),
"[externals]/next/dist/server/app-render/after-task-async-storage.external.js [external] (next/dist/server/app-render/after-task-async-storage.external.js, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("next/dist/server/app-render/after-task-async-storage.external.js", () => require("next/dist/server/app-render/after-task-async-storage.external.js"));

module.exports = mod;
}),
"[externals]/node:crypto [external] (node:crypto, cjs)", ((__turbopack_context__, module, exports) => {

const mod = __turbopack_context__.x("node:crypto", () => require("node:crypto"));

module.exports = mod;
}),
"[project]/apps/admin/src/lib/auth.ts [app-route] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "clearAdminSession",
    ()=>clearAdminSession,
    "readAdminSession",
    ()=>readAdminSession,
    "verifyCredentials",
    ()=>verifyCredentials,
    "writeAdminSession",
    ()=>writeAdminSession
]);
var __TURBOPACK__imported__module__$5b$externals$5d2f$node$3a$crypto__$5b$external$5d$__$28$node$3a$crypto$2c$__cjs$29$__ = __turbopack_context__.i("[externals]/node:crypto [external] (node:crypto, cjs)");
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$headers$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/headers.js [app-route] (ecmascript)");
;
;
const COOKIE_NAME = "indo_admin_session";
function getSecret() {
    const secret = process.env.INDO_PAY_ADMIN_SECRET ?? "replace-me-in-production";
    if ("TURBOPACK compile-time falsy", 0) //TURBOPACK unreachable
    ;
    return secret;
}
function encode(payload) {
    const body = Buffer.from(JSON.stringify(payload), "utf8").toString("base64url");
    const signature = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$node$3a$crypto__$5b$external$5d$__$28$node$3a$crypto$2c$__cjs$29$__["createHmac"])("sha256", getSecret()).update(body).digest("base64url");
    return `${body}.${signature}`;
}
function decode(value) {
    const [body, signature] = value.split(".");
    if (!body || !signature) {
        return null;
    }
    const expected = (0, __TURBOPACK__imported__module__$5b$externals$5d2f$node$3a$crypto__$5b$external$5d$__$28$node$3a$crypto$2c$__cjs$29$__["createHmac"])("sha256", getSecret()).update(body).digest("base64url");
    const provided = Buffer.from(signature, "utf8");
    const computed = Buffer.from(expected, "utf8");
    if (provided.length != computed.length || !(0, __TURBOPACK__imported__module__$5b$externals$5d2f$node$3a$crypto__$5b$external$5d$__$28$node$3a$crypto$2c$__cjs$29$__["timingSafeEqual"])(provided, computed)) {
        return null;
    }
    const payload = JSON.parse(Buffer.from(body, "base64url").toString("utf8"));
    if (payload.exp < Date.now()) {
        return null;
    }
    return payload;
}
async function readAdminSession() {
    const cookieStore = await (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$headers$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__["cookies"])();
    const sessionValue = cookieStore.get(COOKIE_NAME)?.value;
    return sessionValue ? decode(sessionValue) : null;
}
async function writeAdminSession(username) {
    const cookieStore = await (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$headers$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__["cookies"])();
    cookieStore.set(COOKIE_NAME, encode({
        username,
        exp: Date.now() + 12 * 60 * 60 * 1000
    }), {
        httpOnly: true,
        secure: ("TURBOPACK compile-time value", "development") === "production",
        sameSite: "lax",
        path: "/",
        maxAge: 12 * 60 * 60
    });
}
async function clearAdminSession() {
    const cookieStore = await (0, __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$headers$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__["cookies"])();
    cookieStore.delete(COOKIE_NAME);
}
function verifyCredentials(username, password) {
    const expectedUsername = process.env.INDO_PAY_ADMIN_USERNAME ?? "admin";
    const expectedPassword = process.env.INDO_PAY_ADMIN_PASSWORD ?? "indo-pay-admin";
    return safeCompare(username, expectedUsername) && safeCompare(password, expectedPassword);
}
function safeCompare(left, right) {
    const leftBuffer = Buffer.from(left, "utf8");
    const rightBuffer = Buffer.from(right, "utf8");
    if (leftBuffer.length !== rightBuffer.length) {
        return false;
    }
    return (0, __TURBOPACK__imported__module__$5b$externals$5d2f$node$3a$crypto__$5b$external$5d$__$28$node$3a$crypto$2c$__cjs$29$__["timingSafeEqual"])(leftBuffer, rightBuffer);
}
}),
"[project]/apps/admin/src/lib/dashboard-data.ts [app-route] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "buildDashboardCsv",
    ()=>buildDashboardCsv,
    "getDashboardSnapshot",
    ()=>getDashboardSnapshot
]);
function normalizeBaseUrl() {
    const configured = process.env.INDO_PAY_API_URL ?? "http://127.0.0.1:4000/api/v1";
    return configured.endsWith("/") ? configured.slice(0, -1) : configured;
}
async function fetchJson(url) {
    const response = await fetch(url, {
        cache: "no-store",
        headers: {
            Accept: "application/json"
        }
    });
    if (!response.ok) {
        throw new Error(`Backend request failed with status ${response.status}.`);
    }
    return await response.json();
}
async function getDashboardSnapshot() {
    const baseUrl = normalizeBaseUrl();
    const fetchedAt = new Date().toISOString();
    const [dashboardResult, healthResult] = await Promise.allSettled([
        fetchJson(`${baseUrl}/analytics/dashboard`),
        fetchJson(`${baseUrl}/health`)
    ]);
    const backend = healthResult.status === "fulfilled" ? {
        ok: true,
        status: healthResult.value.status ?? "ok",
        checkedAt: healthResult.value.timestamp ?? fetchedAt,
        service: healthResult.value.service ?? "indo-pay-backend",
        url: baseUrl
    } : {
        ok: false,
        status: "unreachable",
        checkedAt: fetchedAt,
        service: "indo-pay-backend",
        url: baseUrl
    };
    if (dashboardResult.status === "fulfilled") {
        return {
            data: dashboardResult.value,
            backend,
            fetchedAt,
            error: null,
            isLive: true
        };
    }
    return {
        data: null,
        backend,
        fetchedAt,
        error: dashboardResult.reason instanceof Error ? dashboardResult.reason.message : "Unable to reach analytics backend.",
        isLive: false
    };
}
function buildDashboardCsv(snapshot) {
    if (!snapshot.data) {
        throw new Error("Dashboard export is unavailable until the analytics API responds.");
    }
    const { data } = snapshot;
    const lines = [
        [
            "metric",
            "value"
        ],
        [
            "gmvToday",
            String(data.gmvToday)
        ],
        [
            "dau",
            String(data.dau)
        ],
        [
            "wau",
            String(data.wau)
        ],
        [
            "rechargeVolume",
            String(data.rechargeVolume)
        ],
        [
            "merchantVolume",
            String(data.merchantVolume)
        ],
        [
            "cashbackIssuedToday",
            String(data.cashbackIssuedToday)
        ],
        [
            "cashbackRedeemedToday",
            String(data.cashbackRedeemedToday)
        ],
        [
            "cashbackExpiredToday",
            String(data.cashbackExpiredToday)
        ],
        [
            "walletLiability",
            String(data.walletLiability)
        ],
        [
            "rewardBurnPercent",
            String(data.rewardBurnPercent)
        ],
        [
            "transactionSuccessRate",
            String(data.transactionSuccessRate)
        ],
        [
            "bankTransferVolume",
            String(data.bankTransferVolume)
        ],
        [
            "imphalMerchants",
            String(data.imphalBetaCohort.merchants)
        ],
        [
            "imphalActiveUsers",
            String(data.imphalBetaCohort.activeUsers)
        ],
        [
            "imphalGmv",
            String(data.imphalBetaCohort.gmv)
        ],
        [],
        [
            "city",
            "merchants",
            "gmv"
        ],
        ...data.cityWiseAdoption.map((city)=>[
                city.city,
                String(city.merchants),
                String(city.gmv)
            ]),
        [],
        [
            "merchantId",
            "orders",
            "volume"
        ],
        ...data.topMerchants.map((merchant)=>[
                merchant.merchantId ?? "unassigned",
                String(merchant.orders),
                String(merchant.volume)
            ])
    ];
    return lines.map((columns)=>columns.map(escapeCsvValue).join(",")).join("\n");
}
function escapeCsvValue(value) {
    if (/[",\n]/.test(value)) {
        return `"${value.replaceAll("\"", "\"\"")}"`;
    }
    return value;
}
}),
"[project]/apps/admin/src/app/api/export/dashboard/route.ts [app-route] (ecmascript)", ((__turbopack_context__) => {
"use strict";

__turbopack_context__.s([
    "GET",
    ()=>GET
]);
var __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$server$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/node_modules/next/server.js [app-route] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$apps$2f$admin$2f$src$2f$lib$2f$auth$2e$ts__$5b$app$2d$route$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/apps/admin/src/lib/auth.ts [app-route] (ecmascript)");
var __TURBOPACK__imported__module__$5b$project$5d2f$apps$2f$admin$2f$src$2f$lib$2f$dashboard$2d$data$2e$ts__$5b$app$2d$route$5d$__$28$ecmascript$29$__ = __turbopack_context__.i("[project]/apps/admin/src/lib/dashboard-data.ts [app-route] (ecmascript)");
;
;
;
async function GET() {
    const session = await (0, __TURBOPACK__imported__module__$5b$project$5d2f$apps$2f$admin$2f$src$2f$lib$2f$auth$2e$ts__$5b$app$2d$route$5d$__$28$ecmascript$29$__["readAdminSession"])();
    if (!session) {
        return __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$server$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__["NextResponse"].json({
            message: "Unauthorized"
        }, {
            status: 401
        });
    }
    const snapshot = await (0, __TURBOPACK__imported__module__$5b$project$5d2f$apps$2f$admin$2f$src$2f$lib$2f$dashboard$2d$data$2e$ts__$5b$app$2d$route$5d$__$28$ecmascript$29$__["getDashboardSnapshot"])();
    if (!snapshot.data) {
        return __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$server$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__["NextResponse"].json({
            message: snapshot.error ?? "Dashboard export unavailable"
        }, {
            status: 503
        });
    }
    const csv = (0, __TURBOPACK__imported__module__$5b$project$5d2f$apps$2f$admin$2f$src$2f$lib$2f$dashboard$2d$data$2e$ts__$5b$app$2d$route$5d$__$28$ecmascript$29$__["buildDashboardCsv"])(snapshot);
    const timestamp = snapshot.fetchedAt.replaceAll(":", "-");
    return new __TURBOPACK__imported__module__$5b$project$5d2f$node_modules$2f$next$2f$server$2e$js__$5b$app$2d$route$5d$__$28$ecmascript$29$__["NextResponse"](csv, {
        status: 200,
        headers: {
            "Content-Type": "text/csv; charset=utf-8",
            "Content-Disposition": `attachment; filename="indo-pay-dashboard-${timestamp}.csv"`,
            "Cache-Control": "no-store"
        }
    });
}
}),
];

//# sourceMappingURL=%5Broot-of-the-server%5D__0wzfp7g._.js.map