import { prisma } from '../../config/prisma';
import { CreateLeaveInput, ReviewLeaveInput, LeaveQueryInput } from './leaves.schema';
import { LeaveStatus } from '../../config/enums';
import { notifyUser } from '../notifications/notifications.service';

// ── Student: submit leave ─────────────────────────────────────────────────────
export const createLeave = async (userId: string, data: CreateLeaveInput) => {
  const fromDate = new Date(data.fromDate);
  const toDate = new Date(data.toDate);
  fromDate.setUTCHours(0, 0, 0, 0);
  toDate.setUTCHours(0, 0, 0, 0);

  return prisma.leaveRequest.create({
    data: { userId, fromDate, toDate, reason: data.reason },
  });
};

// ── Student: my leave history ─────────────────────────────────────────────────
export const getMyLeaves = async (userId: string, query: LeaveQueryInput) => {
  const where: Record<string, unknown> = { userId };
  if (query.status) where.status = query.status;

  const [leaves, total] = await Promise.all([
    prisma.leaveRequest.findMany({
      where,
      skip: (query.page - 1) * query.limit,
      take: query.limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.leaveRequest.count({ where }),
  ]);
  return { leaves, total, page: query.page, limit: query.limit };
};

// ── Student: cancel pending leave ─────────────────────────────────────────────
export const cancelLeave = async (userId: string, leaveId: string) => {
  const leave = await prisma.leaveRequest.findUnique({ where: { id: leaveId } });
  if (!leave || leave.userId !== userId) throw new Error('Leave request not found');
  if (leave.status !== LeaveStatus.PENDING) {
    throw new Error('Only pending leave requests can be cancelled');
  }
  return prisma.leaveRequest.update({
    where: { id: leaveId },
    data: { status: LeaveStatus.CANCELLED },
  });
};

// ── Admin: list all leave requests ───────────────────────────────────────────
export const adminListLeaves = async (query: LeaveQueryInput) => {
  const where: Record<string, unknown> = {};
  if (query.status) where.status = query.status;

  const [leaves, total] = await Promise.all([
    prisma.leaveRequest.findMany({
      where,
      skip: (query.page - 1) * query.limit,
      take: query.limit,
      orderBy: { createdAt: 'desc' },
      include: {
        user: { select: { id: true, name: true, email: true, rollNumber: true } },
      },
    }),
    prisma.leaveRequest.count({ where }),
  ]);
  return { leaves, total, page: query.page, limit: query.limit };
};

// ── Admin: approve or reject ──────────────────────────────────────────────────
export const reviewLeave = async (
  adminId: string,
  leaveId: string,
  data: ReviewLeaveInput,
) => {
  const leave = await prisma.leaveRequest.findUnique({
    where: { id: leaveId },
    include: { user: true },
  });
  if (!leave) throw new Error('Leave request not found');
  if (leave.status !== LeaveStatus.PENDING) {
    throw new Error('Leave request is no longer pending');
  }

  const updated = await prisma.leaveRequest.update({
    where: { id: leaveId },
    data: {
      status: data.status,
      reviewedBy: adminId,
      reviewedAt: new Date(),
      reviewNote: data.reviewNote,
    },
  });

  // Notify student
  const statusLabel = data.status === LeaveStatus.APPROVED ? 'approved ✅' : 'rejected ❌';
  await notifyUser(leave.userId, {
    title: `Leave Request ${statusLabel}`,
    body: data.reviewNote
      ? `Your leave (${leave.fromDate.toDateString()} – ${leave.toDate.toDateString()}) was ${statusLabel}. Note: ${data.reviewNote}`
      : `Your leave (${leave.fromDate.toDateString()} – ${leave.toDate.toDateString()}) was ${statusLabel}.`,
  }).catch(() => { /* silent */ });

  return updated;
};
