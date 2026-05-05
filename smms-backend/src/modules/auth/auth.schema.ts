import { z } from 'zod';

export const RequestOtpSchema = z.object({
  email: z.string().email('Must be a valid email address'),
});

export const LoginSchema = z.object({
  email: z.string().email('Must be a valid email address'),
  role: z.string().min(1, 'Role is required'),
});

export const VerifyOtpSchema = z.object({
  email: z.string().email(),
  otp: z.string().length(6, 'OTP must be exactly 6 digits').regex(/^\d+$/, 'OTP must be numeric'),
});

export const RefreshTokenSchema = z.object({
  refreshToken: z.string().min(1, 'Refresh token is required'),
});

export type RequestOtpInput = z.infer<typeof RequestOtpSchema>;
export type LoginInput = z.infer<typeof LoginSchema>;
export type VerifyOtpInput = z.infer<typeof VerifyOtpSchema>;
export type RefreshTokenInput = z.infer<typeof RefreshTokenSchema>;
