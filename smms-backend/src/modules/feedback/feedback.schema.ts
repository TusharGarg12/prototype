import { z } from 'zod';
import { MealSlot } from '../../config/enums';

export const CreateFeedbackSchema = z.object({
  mealSlot: z.nativeEnum(MealSlot).optional(),
  mealDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  rating: z.number().int().min(1).max(5).optional(),
  message: z.string().min(1).optional(),
  isAnon: z.boolean().default(false),
}).refine(d => d.rating !== undefined || d.message !== undefined, {
  message: 'Provide at least a rating or a message',
});

export const FeedbackQuerySchema = z.object({
  from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  mealSlot: z.nativeEnum(MealSlot).optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type CreateFeedbackInput = z.infer<typeof CreateFeedbackSchema>;
export type FeedbackQueryInput = z.infer<typeof FeedbackQuerySchema>;
