import { z } from 'zod';
import { MealSlot } from '../../config/enums';

export const CreateInventoryItemSchema = z.object({
  name: z.string().min(1),
  unit: z.string().min(1),
  currentStock: z.number().nonnegative(),
  lowStockLevel: z.number().nonnegative(),
  mealMappings: z
    .array(
      z.object({
        mealSlot: z.nativeEnum(MealSlot),
        portionQty: z.number().positive(),
      }),
    )
    .optional(),
});

export const UpdateInventoryItemSchema = z.object({
  currentStock: z.number().nonnegative().optional(),
  lowStockLevel: z.number().nonnegative().optional(),
  mealMappings: z
    .array(
      z.object({
        mealSlot: z.nativeEnum(MealSlot),
        portionQty: z.number().positive(),
      }),
    )
    .optional(),
});

export type CreateInventoryItemInput = z.infer<typeof CreateInventoryItemSchema>;
export type UpdateInventoryItemInput = z.infer<typeof UpdateInventoryItemSchema>;
