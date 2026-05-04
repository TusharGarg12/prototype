import { z } from 'zod';
import { LeaveStatus } from '../../config/enums';

export const CreateLeaveSchema = z.object({
  fromDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Use YYYY-MM-DD'),
  toDate: z.string().regex(/^\d{4}-\d{2}-\d{2}$/, 'Use YYYY-MM-DD'),
  reason: z.string().optional(),
}).refine(d => new Date(d.fromDate) <= new Date(d.toDate), {
  message: 'fromDate must be on or before toDate',
  path: ['fromDate'],
});

export const ReviewLeaveSchema = z.object({
  status: z.enum([LeaveStatus.APPROVED, LeaveStatus.REJECTED]),
  reviewNote: z.string().optional(),
});

export const LeaveQuerySchema = z.object({
  status: z.nativeEnum(LeaveStatus).optional(),
  page: z.coerce.number().int().positive().default(1),
  limit: z.coerce.number().int().positive().max(100).default(20),
});

export type CreateLeaveInput = z.infer<typeof CreateLeaveSchema>;
export type ReviewLeaveInput = z.infer<typeof ReviewLeaveSchema>;
export type LeaveQueryInput = z.infer<typeof LeaveQuerySchema>;
