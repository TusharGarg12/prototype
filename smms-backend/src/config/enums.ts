// TypeScript-level enums — replace Prisma enums (not supported in SQLite).
// Use these everywhere instead of @prisma/client enum imports.

export enum Role {
  STUDENT = 'STUDENT',
  ADMIN = 'ADMIN',
  KITCHEN_STAFF = 'KITCHEN_STAFF',
}

export enum MealSlot {
  BREAKFAST = 'BREAKFAST',
  LUNCH = 'LUNCH',
  SNACKS = 'SNACKS',
  DINNER = 'DINNER',
}

export enum LeaveStatus {
  PENDING = 'PENDING',
  APPROVED = 'APPROVED',
  REJECTED = 'REJECTED',
  CANCELLED = 'CANCELLED',
}

export enum QRStatus {
  VALID = 'VALID',
  USED = 'USED',
  EXPIRED = 'EXPIRED',
  BLOCKED = 'BLOCKED',
}

export enum NotificationChannel {
  IN_APP = 'IN_APP',
  EMAIL = 'EMAIL',
}
