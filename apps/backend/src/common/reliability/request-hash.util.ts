import { createHash, createHmac, timingSafeEqual } from "node:crypto";

type JsonLike =
  | string
  | number
  | boolean
  | null
  | JsonLike[]
  | { readonly [key: string]: JsonLike | undefined };

function normalizeValue(value: unknown): JsonLike {
  if (Array.isArray(value)) {
    return value.map((item) => normalizeValue(item));
  }

  if (value && typeof value === "object") {
    return Object.keys(value)
      .sort()
      .reduce<Record<string, JsonLike>>((accumulator, key) => {
        const nestedValue = (value as Record<string, unknown>)[key];
        if (nestedValue !== undefined) {
          accumulator[key] = normalizeValue(nestedValue);
        }

        return accumulator;
      }, {});
  }

  return value as JsonLike;
}

export function stableStringify(value: unknown) {
  return JSON.stringify(normalizeValue(value));
}

export function hashString(value: string) {
  return createHash("sha256").update(value).digest("hex");
}

export function hashPayload(value: unknown) {
  return hashString(stableStringify(value));
}

export function createTransactionReferenceHash(parts: Array<string | number | boolean | null | undefined>) {
  return hashString(parts.filter((part) => part !== undefined && part !== null).join("|"));
}

export function createHmacSignature(payload: string, secret: string) {
  return createHmac("sha256", secret).update(payload).digest("hex");
}

export function verifyHmacSignature(payload: string, signature: string, secret: string) {
  const computed = Buffer.from(createHmacSignature(payload, secret), "utf8");
  const provided = Buffer.from(signature, "utf8");

  if (computed.length !== provided.length) {
    return false;
  }

  return timingSafeEqual(computed, provided);
}
