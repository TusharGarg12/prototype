import { prisma } from '../../config/prisma';
import { NotificationChannel, Role } from '../../config/enums';
import { NotificationQueryInput } from './notifications.schema';

interface NotifyPayload {
  title: string;
  body: string;
  channel?: NotificationChannel;
}

// ── Send to one user ──────────────────────────────────────────────────────────
export const notifyUser = async (userId: string, payload: NotifyPayload) => {
  return prisma.notification.create({
    data: {
      userId,
      title: payload.title,
      body: payload.body,
      channel: payload.channel ?? NotificationChannel.IN_APP,
    },
  });
};

// ── Broadcast to all users with a given role ──────────────────────────────────
export const notifyRole = async (role: Role, payload: NotifyPayload) => {
  const users = await prisma.user.findMany({
    where: { role, isActive: true },
    select: { id: true },
  });

  if (users.length === 0) return;

  for (const u of users) {
    await prisma.notification.create({
      data: {
        userId: u.id,
        title: payload.title,
        body: payload.body,
        channel: payload.channel ?? NotificationChannel.IN_APP,
      },
    });
  }
};

// ── Student: get my notifications ─────────────────────────────────────────────
export const getMyNotifications = async (userId: string, query: NotificationQueryInput) => {
  const where: Record<string, unknown> = { userId };
  if (query.unreadOnly) where.isRead = false;

  const [notifications, total] = await Promise.all([
    prisma.notification.findMany({
      where,
      skip: (query.page - 1) * query.limit,
      take: query.limit,
      orderBy: { createdAt: 'desc' },
    }),
    prisma.notification.count({ where }),
  ]);

  return { notifications, total, page: query.page, limit: query.limit };
};

// ── Mark one notification as read ─────────────────────────────────────────────
export const markRead = async (userId: string, notificationId: string) => {
  const n = await prisma.notification.findUnique({ where: { id: notificationId } });
  if (!n || n.userId !== userId) throw new Error('Notification not found');

  return prisma.notification.update({
    where: { id: notificationId },
    data: { isRead: true },
  });
};

// ── Mark all as read ──────────────────────────────────────────────────────────
export const markAllRead = async (userId: string) => {
  await prisma.notification.updateMany({
    where: { userId, isRead: false },
    data: { isRead: true },
  });
};
