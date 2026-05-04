-- CreateTable
CREATE TABLE "PredictionData" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "mealDate" DATETIME NOT NULL,
    "mealSlot" TEXT NOT NULL,
    "predictedCount" INTEGER NOT NULL,
    "actualCount" INTEGER,
    "confidenceScore" REAL,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);

-- RedefineTables
PRAGMA defer_foreign_keys=ON;
PRAGMA foreign_keys=OFF;
CREATE TABLE "new_User" (
    "id" TEXT NOT NULL PRIMARY KEY,
    "email" TEXT NOT NULL,
    "rollNumber" TEXT,
    "name" TEXT NOT NULL,
    "role" TEXT NOT NULL DEFAULT 'STUDENT',
    "photoUrl" TEXT,
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "rewardPoints" INTEGER NOT NULL DEFAULT 0,
    "createdAt" DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" DATETIME NOT NULL
);
INSERT INTO "new_User" ("createdAt", "email", "id", "isActive", "name", "photoUrl", "role", "rollNumber", "updatedAt") SELECT "createdAt", "email", "id", "isActive", "name", "photoUrl", "role", "rollNumber", "updatedAt" FROM "User";
DROP TABLE "User";
ALTER TABLE "new_User" RENAME TO "User";
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
CREATE UNIQUE INDEX "User_rollNumber_key" ON "User"("rollNumber");
PRAGMA foreign_keys=ON;
PRAGMA defer_foreign_keys=OFF;

-- CreateIndex
CREATE UNIQUE INDEX "PredictionData_mealDate_mealSlot_key" ON "PredictionData"("mealDate", "mealSlot");
