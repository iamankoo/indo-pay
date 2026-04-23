import { redirect } from "next/navigation";

import { LoginForm } from "@/components/login/login-form";
import { readAdminSession } from "@/lib/auth";

export default async function LoginPage() {
  const session = await readAdminSession();
  if (session) {
    redirect("/");
  }

  return (
    <main className="flex min-h-screen items-center justify-center p-6">
      <LoginForm />
    </main>
  );
}
