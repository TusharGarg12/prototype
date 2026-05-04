import { z } from 'zod';

export const CreateDishSchema = z.object({
  name: z.string().min(1),
  category: z.string().min(1),
  isVeg: z.boolean().default(true),
  description: z.string().optional(),
});

export const UpdateDishSchema = z.object({
  name: z.string().min(1).optional(),
  category: z.string().optional(),
  isVeg: z.boolean().optional(),
  description: z.string().optional(),
  isActive: z.boolean().optional(),
});

export type CreateDishInput = z.infer<typeof CreateDishSchema>;
export type UpdateDishInput = z.infer<typeof UpdateDishSchema>;
