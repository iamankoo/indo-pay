import { NextResponse } from "next/server";

import { verifyCredentials, writeAdminSession } from "@/lib/auth";

export async function POST(request: Request) {
  const body = (await request.json()) as {
    username?: string;
    password?: string;
  };

  if (!body.username || !body.password || !verifyCredentials(body.username, body.password)) {
    return NextResponse.json(
      { message: "Invalid admin credentials" },
      { status: 401 }
    );
  }

  await writeAdminSession(body.username);
  return NextResponse.json({ ok: true });
}
