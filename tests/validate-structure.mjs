import test from "node:test";
import assert from "node:assert/strict";
import { existsSync } from "node:fs";
import path from "node:path";

const root = path.resolve(import.meta.dirname, "..");

const requiredPaths = [
  "apps/backend/package.json",
  "apps/backend/docker-compose.yml",
  "apps/backend/prisma/schema.prisma",
  "apps/backend/prisma/migrations/0001_init/migration.sql",
  "apps/backend/src/main.ts",
  "apps/backend/src/common/reliability/idempotency.service.ts",
  "apps/backend/src/common/redis/wallet-lock.service.ts",
  "apps/backend/src/modules/health/health.controller.ts",
  "apps/backend/src/modules/passbook/passbook.controller.ts",
  "apps/backend/src/modules/bank-transfers/bank-transfers.controller.ts",
  "apps/backend/src/modules/merchants/merchants.controller.ts",
  "apps/mobile/pubspec.yaml",
  "apps/mobile/lib/main.dart",
  "apps/mobile/lib/core/routing/app_router.dart",
  "apps/mobile/lib/features/passbook/presentation/passbook_screen.dart",
  "apps/mobile/lib/features/bank_transfer/presentation/bank_transfer_screen.dart",
  "apps/mobile/lib/features/merchant/presentation/merchant_screen.dart",
  "apps/admin/package.json",
  "apps/admin/src/app/(dashboard)/page.tsx",
  "apps/admin/src/app/login/page.tsx",
  "docs/api-contracts.md",
  "docs/backend-checkpoint.md",
  "docs/deployment-guide.md",
  "docs/deployment-checklist.md",
  "docs/beta-release-checklist.md",
  "docs/production-structure.md",
  "docs/security-checklist.md",
  "packages/shared/src/reward-engine.js"
];

test("repo includes required scaffold files", () => {
  for (const relativePath of requiredPaths) {
    assert.equal(
      existsSync(path.join(root, relativePath)),
      true,
      `Missing ${relativePath}`
    );
  }
});
