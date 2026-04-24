-- CreateTable
CREATE TABLE "AppRelease" (
    "id" TEXT NOT NULL,
    "latestVersion" TEXT NOT NULL,
    "buildNumber" INTEGER NOT NULL,
    "forceUpdate" BOOLEAN NOT NULL DEFAULT false,
    "apkUrl" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "releaseNotes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "AppRelease_pkey" PRIMARY KEY ("id")
);
