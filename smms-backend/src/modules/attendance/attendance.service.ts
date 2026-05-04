import { prisma } from '../../config/prisma';
import { AttendanceQueryInput } from './attendance.schema';

// ── Student: my attendance history ───────────────────────────────────────────
export const getMyAttendance = async (userId: string, query: AttendanceQueryInput) => {
  const { from, to, mealSlot, page, limit } = query;

  const where: Record<string, unknown> = { userId };
  if (mealSlot) where.mealSlot = mealSlot;
  if (from || to) {
    where.mealDate = {
      ...(from ? { gte: new Date(from) } : {}),
      ...(to ? { lte: new Date(to) } : {}),
    };
  }

  const [logs, total] = await Promise.all([
    prisma.attendanceLog.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { mealDate: 'desc' },
      select: { id: true, mealSlot: true, mealDate: true, scannedAt: true, isOverride: true },
    }),
    prisma.attendanceLog.count({ where }),
  ]);

  return { logs, total, page, limit };
};

// ── Admin: attendance with filters ───────────────────────────────────────────
export const getAdminAttendance = async (query: AttendanceQueryInput) => {
  const { from, to, mealSlot, page, limit } = query;

  const where: Record<string, unknown> = {};
  if (mealSlot) where.mealSlot = mealSlot;
  if (from || to) {
    where.mealDate = {
      ...(from ? { gte: new Date(from) } : {}),
      ...(to ? { lte: new Date(to) } : {}),
    };
  }

  const [logs, total] = await Promise.all([
    prisma.attendanceLog.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { scannedAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, email: true, rollNumber: true } },
      },
    }),
    prisma.attendanceLog.count({ where }),
  ]);

  return { logs, total, page, limit };
};

// ── Admin: footfall summary per slot per date ─────────────────────────────────
export const getFootfallSummary = async (date: string) => {
  const mealDate = new Date(date);
  const results = await prisma.attendanceLog.groupBy({
    by: ['mealSlot'],
    where: { mealDate },
    _count: { id: true },
  });
  return results.map(r => ({ mealSlot: r.mealSlot, count: r._count.id }));
};
