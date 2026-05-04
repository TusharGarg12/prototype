import { z } from 'zod';
import { MealSlot } from '../../config/enums';

export const GenerateQRSchema = z.object({
  mealSlot: z.nativeEnum(MealSlot).optional(), // auto-detect from time if omitted
});

export const ValidateQRSchema = z.object({
  token: z.string().min(1, 'QR token is required'),
  counterId: z.string().optional(),
});

export const OverrideAttendanceSchema = z.object({
  studentId: z.string().uuid(),
  mealSlot: z.nativeEnum(MealSlot),
  reason: z.string().min(5, 'Please provide a reason for the override'),
  counterId: z.string().optional(),
});

export type GenerateQRInput = z.infer<typeof GenerateQRSchema>;
export type ValidateQRInput = z.infer<typeof ValidateQRSchema>;
export type OverrideAttendanceInput = z.infer<typeof OverrideAttendanceSchema>;
