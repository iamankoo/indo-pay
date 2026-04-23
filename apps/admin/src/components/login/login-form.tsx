"use client";

import { useRouter } from "next/navigation";
import { useState, type FormEvent } from "react";

import { Button } from "@/components/ui/button";
import { Card } from "@/components/ui/card";
import { Input } from "@/components/ui/input";

export function LoginForm() {
  const router = useRouter();
  const [username, setUsername] = useState("");
  const [password, setPassword] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [pending, setPending] = useState(false);

  async function onSubmit(event: FormEvent<HTMLFormElement>) {
    event.preventDefault();
    setPending(true);
    setError(null);

    const response = await fetch("/api/login", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
      },
      body: JSON.stringify({ username, password }),
    }).catch(() => null);

    if (!response || !response.ok) {
      const payload = response
        ? ((await response.json()) as { message?: string })
        : null;
      setError(payload?.message ?? "Unable to sign in");
      setPending(false);
      return;
    }

    router.replace("/");
    router.refresh();
  }

  return (
    <Card className="w-full max-w-md space-y-6">
      <div>
        <p className="text-sm text-muted-foreground">Founder control center</p>
        <h1 className="mt-2 text-3xl font-semibold tracking-tight">
          Indo Pay Admin
        </h1>
        <p className="mt-3 text-sm text-muted-foreground">
          Use the beta admin credentials configured for this environment.
        </p>
      </div>
      <form className="space-y-4" onSubmit={onSubmit}>
        <Input
          value={username}
          onChange={(event) => setUsername(event.target.value)}
          placeholder="Username"
        />
        <Input
          value={password}
          onChange={(event) => setPassword(event.target.value)}
          placeholder="Password"
          type="password"
        />
        {error ? <p className="text-sm text-red-300">{error}</p> : null}
        <Button className="w-full" disabled={pending} type="submit">
          {pending ? "Signing in..." : "Sign in"}
        </Button>
      </form>
    </Card>
  );
}
