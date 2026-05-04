import { z } from 'zod';
import { MealSlot } from '../../config/enums';

export const AttendanceQuerySchema = z.object({
  from: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Use YYYY-MM-DD').optional(),
  to: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Use YYYY-MM-DD').optional(),
  mealSlot: z.nativeEnum(MealSlot).optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type AttendanceQueryInput = z.infer<typeof AttendanceQuerySchema>;
