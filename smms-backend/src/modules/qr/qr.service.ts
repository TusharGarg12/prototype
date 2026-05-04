import { prisma } from '../../config/prisma';
import { generateQRToken, hashToken } from '../../utils/qrToken';
import { getCurrentMealSlot, todayDate, qrExpiresAt } from '../../utils/mealWindow';
import { env } from '../../config/env';
import { MealSlot, QRStatus, Role } from '../../config/enums';
import { notifyUser } from '../notifications/notifications.service';
import { decrementInventoryForMeal } from '../inventory/inventory.service';
import { OverrideAttendanceInput } from './qr.schema';

// ── Generate QR Pass (Student) ────────────────────────────────────────────────
export const generateQRPass = async (userId: string, requestedSlot?: MealSlot) => {
  const mealSlot = requestedSlot ?? getCurrentMealSlot();
  if (!mealSlot) throw new Error('No active meal slot right now');

  const mealDate = todayDate();

  // Check if student has an approved leave covering today
  const activeLeave = await prisma.leaveRequest.findFirst({
    where: {
      userId,
      status: 'APPROVED',
      fromDate: { lte: mealDate },
      toDate: { gte: mealDate },
    },
  });
  if (activeLeave) throw new Error('You have an approved leave for today');

  // Return existing VALID pass (idempotent)
  const existing = await prisma.qRPass.findUnique({
    where: { userId_mealSlot_mealDate: { userId, mealSlot, mealDate } },
  });

  if (existing) {
    // If it's still valid, re-issue the token (we can't recover the raw token
    // from the hash — so we regenerate and update when still unused)
    if (existing.status === QRStatus.USED) {
      throw new Error('You have already collected your meal for this slot');
    }
    if (existing.status === QRStatus.BLOCKED) {
      throw new Error('Your QR pass is blocked. Contact the mess admin');
    }
    // Expired or valid → generate a fresh token with a new 30-min window
    const { raw, hashed } = generateQRToken();
    const expiresAt = qrExpiresAt(env.QR_WINDOW_MINUTES);
    await prisma.qRPass.update({
      where: { id: existing.id },
      data: { token: hashed, status: QRStatus.VALID, expiresAt },
    });
    return { token: raw, mealSlot, mealDate, expiresAt };
  }

  // Create new QR pass
  const { raw, hashed } = generateQRToken();
  const expiresAt = qrExpiresAt(env.QR_WINDOW_MINUTES);

  await prisma.qRPass.create({
    data: { userId, mealSlot, mealDate, token: hashed, expiresAt },
  });

  return { token: raw, mealSlot, mealDate, expiresAt };
};

// ── Validate QR Pass (Admin / Kitchen Staff) — atomic, anti-replay ────────────
export const validateQRPass = async (
  rawToken: string,
  operatorId: string,
  counterId?: string,
) => {
  const hashed = hashToken(rawToken);

  // Use a transaction to atomically find-and-mark to prevent race conditions
  return prisma.$transaction(async (tx) => {
    const pass = await tx.qRPass.findUnique({ where: { token: hashed } });

    if (!pass) throw new Error('QR pass not found');
    if (pass.status === QRStatus.USED) throw new Error('QR pass already used');
    if (pass.status === QRStatus.BLOCKED) throw new Error('QR pass blocked');
    if (pass.status === QRStatus.EXPIRED || pass.expiresAt < new Date()) {
      await tx.qRPass.update({ where: { id: pass.id }, data: { status: QRStatus.EXPIRED } });
      throw new Error('QR pass expired');
    }

    // Mark as USED (atomic within transaction)
    await tx.qRPass.update({
      where: { id: pass.id },
      data: { status: QRStatus.USED },
    });

    // Create attendance log
    const log = await tx.attendanceLog.create({
      data: {
        userId: pass.userId,
        qrPassId: pass.id,
        mealSlot: pass.mealSlot,
        mealDate: pass.mealDate,
        counterId,
        operatorId,
        isOverride: false,
      },
    });
    // Surge Management Phase 2: Check for off-peak points
    const currentHr = new Date().getHours();
    const currentMin = new Date().getMinutes();
    let pointsAwarded = 0;
    
    // Example logic: Off-peak Lunch (1:30 PM - 2:00 PM / 13:30 - 14:00)
    if (pass.mealSlot === 'LUNCH' && currentHr === 13 && currentMin >= 30) {
      pointsAwarded = 10;
    }
    // Example logic: Off-peak Dinner (8:30 PM - 9:00 PM / 20:30 - 21:00)
    else if (pass.mealSlot === 'DINNER' && currentHr === 20 && currentMin >= 30) {
      pointsAwarded = 10;
    }

    if (pointsAwarded > 0) {
       await tx.user.update({
         where: { id: pass.userId },
         data: { rewardPoints: { increment: pointsAwarded } }
       });
       // Optional: Add notification
       await tx.notification.create({
         data: {
           userId: pass.userId,
           title: 'Off-Peak Reward!',
           body: `You earned ${pointsAwarded} points for dining during off-peak hours.`
         }
       });
    }
    // Auto-decrement inventory (runs inside the same transaction)
    await decrementInventoryForMeal(pass.mealSlot, tx);

    return { log, studentId: pass.userId, mealSlot: pass.mealSlot };
  }).then(async (result) => {
    // Notify student (outside transaction — non-critical)
    await notifyUser(result.studentId, {
      title: 'Meal Collected ✅',
      body: `Your ${result.mealSlot.toLowerCase()} has been successfully recorded.`,
    }).catch(() => { /* silent */ });

    return result.log;
  });
};

// ── Manual Override (Admin) ───────────────────────────────────────────────────
export const overrideAttendance = async (
  operatorId: string,
  input: OverrideAttendanceInput,
) => {
  const mealDate = todayDate();

  return prisma.$transaction(async (tx) => {
    // Prevent duplicate override
    const existingLog = await tx.attendanceLog.findFirst({
      where: { userId: input.studentId, mealSlot: input.mealSlot, mealDate },
    });
    if (existingLog) throw new Error('Attendance already recorded for this student and slot');

    // Create a synthetic QR pass marked USED for audit completeness
    const { raw, hashed } = generateQRToken();
    const pass = await tx.qRPass.create({
      data: {
        userId: input.studentId,
        mealSlot: input.mealSlot,
        mealDate,
        token: hashed,
        status: QRStatus.USED,
        expiresAt: new Date(),
      },
    });

    const log = await tx.attendanceLog.create({
      data: {
        userId: input.studentId,
        qrPassId: pass.id,
        mealSlot: input.mealSlot,
        mealDate,
        counterId: input.counterId,
        operatorId,
        isOverride: true,
      },
    });

    await tx.attendanceOverrideLog.create({
      data: {
        studentId: input.studentId,
        operatorId,
        mealSlot: input.mealSlot,
        mealDate,
        reason: input.reason,
      },
    });

    await decrementInventoryForMeal(input.mealSlot, tx);

    return log;
  });
};
