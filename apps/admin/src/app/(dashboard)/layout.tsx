import { LogOut } from "lucide-react";
import { redirect } from "next/navigation";
import type { ReactNode } from "react";

import { Button } from "@/components/ui/button";
import { readAdminSession } from "@/lib/auth";

export default async function DashboardLayout({
  children,
}: Readonly<{
  children: ReactNode;
}>) {
  const session = await readAdminSession();
  if (!session) {
    redirect("/login");
  }

  return (
    <div className="min-h-screen px-6 pb-10 pt-6 lg:px-10">
      <header className="mb-8 flex flex-col gap-4 lg:flex-row lg:items-center lg:justify-between">
        <div>
          <p className="text-sm text-muted-foreground">
            Operations, growth, and investor reporting
          </p>
          <h1 className="mt-2 text-4xl font-semibold tracking-tight">
            Indo Pay command deck
          </h1>
        </div>
        <form action="/api/logout" method="post">
          <Button type="submit" variant="secondary">
            <LogOut className="mr-2 h-4 w-4" />
            Sign out
          </Button>
        </form>
      </header>
      {children}
    </div>
  );
}
