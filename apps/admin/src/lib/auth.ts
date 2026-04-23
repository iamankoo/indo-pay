import { createHmac, timingSafeEqual } from "node:crypto";

import { cookies } from "next/headers";

const COOKIE_NAME = "indo_admin_session";

interface SessionPayload {
  readonly username: string;
  readonly exp: number;
}

function getSecret() {
  const secret = process.env.INDO_PAY_ADMIN_SECRET ?? "replace-me-in-production";
  if (process.env.NODE_ENV === "production" && secret === "replace-me-in-production") {
    throw new Error("INDO_PAY_ADMIN_SECRET must be configured in production.");
  }

  return secret;
}

function encode(payload: SessionPayload) {
  const body = Buffer.from(JSON.stringify(payload), "utf8").toString("base64url");
  const signature = createHmac("sha256", getSecret()).update(body).digest("base64url");
  return `${body}.${signature}`;
}

function decode(value: string) {
  const [body, signature] = value.split(".");
  if (!body || !signature) {
    return null;
  }

  const expected = createHmac("sha256", getSecret()).update(body).digest("base64url");
  const provided = Buffer.from(signature, "utf8");
  const computed = Buffer.from(expected, "utf8");

  if (provided.length != computed.length || !timingSafeEqual(provided, computed)) {
    return null;
  }

  const payload = JSON.parse(Buffer.from(body, "base64url").toString("utf8")) as SessionPayload;
  if (payload.exp < Date.now()) {
    return null;
  }

  return payload;
}

export async function readAdminSession() {
  const cookieStore = await cookies();
  const sessionValue = cookieStore.get(COOKIE_NAME)?.value;
  return sessionValue ? decode(sessionValue) : null;
}

export async function writeAdminSession(username: string) {
  const cookieStore = await cookies();
  cookieStore.set(COOKIE_NAME, encode({
    username,
    exp: Date.now() + 12 * 60 * 60 * 1000,
  }), {
    httpOnly: true,
    secure: process.env.NODE_ENV === "production",
    sameSite: "lax",
    path: "/",
    maxAge: 12 * 60 * 60,
  });
}

export async function clearAdminSession() {
  const cookieStore = await cookies();
  cookieStore.delete(COOKIE_NAME);
}

export function verifyCredentials(username: string, password: string) {
  const expectedUsername = process.env.INDO_PAY_ADMIN_USERNAME ?? "admin";
  const expectedPassword = process.env.INDO_PAY_ADMIN_PASSWORD ?? "indo-pay-admin";

  return safeCompare(username, expectedUsername) && safeCompare(password, expectedPassword);
}

function safeCompare(left: string, right: string) {
  const leftBuffer = Buffer.from(left, "utf8");
  const rightBuffer = Buffer.from(right, "utf8");

  if (leftBuffer.length !== rightBuffer.length) {
    return false;
  }

  return timingSafeEqual(leftBuffer, rightBuffer);
}
