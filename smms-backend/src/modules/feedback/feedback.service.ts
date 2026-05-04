import { prisma } from '../../config/prisma';
import { CreateFeedbackInput, FeedbackQueryInput } from './feedback.schema';

// ── Student: submit feedback ──────────────────────────────────────────────────
export const createFeedback = async (userId: string, data: CreateFeedbackInput) => {
  const mealDate = data.mealDate ? new Date(data.mealDate) : undefined;
  if (mealDate) mealDate.setUTCHours(0, 0, 0, 0);

  return prisma.feedback.create({
    data: {
      userId,
      mealSlot: data.mealSlot,
      mealDate,
      rating: data.rating,
      message: data.message,
      isAnon: data.isAnon,
    },
  });
};

// ── Admin: list all feedback ──────────────────────────────────────────────────
export const adminListFeedback = async (query: FeedbackQueryInput) => {
  const where: Record<string, unknown> = {};
  if (query.mealSlot) where.mealSlot = query.mealSlot;
  if (query.from) {
    const from = new Date(query.from);
    from.setUTCHours(0, 0, 0, 0);
    where.mealDate = { gte: from };
  }

  const [feedbacks, total] = await Promise.all([
    prisma.feedback.findMany({
      where,
      skip: (query.page - 1) * query.limit,
      take: query.limit,
      orderBy: { createdAt: 'desc' },
      include: {
        // Mask identity for anonymous submissions
        user: { select: { id: true, name: true, rollNumber: true } },
      },
    }),
    prisma.feedback.count({ where }),
  ]);

  // Redact user identity for anonymous entries
  const sanitised = feedbacks.map(f => ({
    ...f,
    user: f.isAnon ? null : f.user,
  }));

  return { feedbacks: sanitised, total, page: query.page, limit: query.limit };
};

// ── Admin: average rating summary ────────────────────────────────────────────
export const getRatingSummary = async (date: string) => {
  const mealDate = new Date(date);
  mealDate.setUTCHours(0, 0, 0, 0);

  const result = await prisma.feedback.groupBy({
    by: ['mealSlot'],
    where: { mealDate, rating: { not: null } },
    _avg: { rating: true },
    _count: { rating: true },
  });

  return result.map(r => ({
    mealSlot: r.mealSlot,
    avgRating: r._avg.rating,
    count: r._count.rating,
  }));
};
