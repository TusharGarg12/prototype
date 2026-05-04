import { z } from 'zod';
import { Role } from '../../config/enums';

// ── Student self ──────────────────────────────────────────────────────────────
export const UpdateMeSchema = z.object({
  name: z.string().min(1).optional(),
  rollNumber: z.string().optional(),
  photoUrl: z.string().url().optional(),
});

// ── Admin: create user ────────────────────────────────────────────────────────
export const CreateUserSchema = z.object({
  email: z.string().email(),
  name: z.string().min(1),
  role: z.nativeEnum(Role).default(Role.STUDENT),
  rollNumber: z.string().optional(),
});

// ── Admin: update user ────────────────────────────────────────────────────────
export const AdminUpdateUserSchema = z.object({
  name: z.string().min(1).optional(),
  role: z.nativeEnum(Role).optional(),
  isActive: z.boolean().optional(),
});

export type UpdateMeInput = z.infer<typeof UpdateMeSchema>;
export type CreateUserInput = z.infer<typeof CreateUserSchema>;
export type AdminUpdateUserInput = z.infer<typeof AdminUpdateUserSchema>;
