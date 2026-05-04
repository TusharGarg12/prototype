import { z } from 'zod';
import { MealSlot } from '../../config/enums';

export const CreateMenuSchema = z.object({
  mealSlot: z.nativeEnum(MealSlot),
  menuDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Use YYYY-MM-DD'),
  dishIds: z.array(z.string().uuid()).min(1, 'At least one dish required'),
  isPublished: z.boolean().default(false),
});

export const UpdateMenuSchema = z.object({
  dishIds: z.array(z.string().uuid()).optional(),
  isPublished: z.boolean().optional(),
});

export const MenuQuerySchema = z.object({
  date: z.string().regex(/^\d{4}-\d{2}-\d{2}$/).optional(),
  mealSlot: z.nativeEnum(MealSlot).optional(),
});

export type CreateMenuInput = z.infer<typeof CreateMenuSchema>;
export type UpdateMenuInput = z.infer<typeof UpdateMenuSchema>;
export type MenuQueryInput = z.infer<typeof MenuQuerySchema>;
