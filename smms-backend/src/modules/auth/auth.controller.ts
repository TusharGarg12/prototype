import { Request, Response, NextFunction } from 'express';
import * as AuthService from './auth.service';
import { LoginSchema, RequestOtpSchema, VerifyOtpSchema, RefreshTokenSchema } from './auth.schema';
import { ok, created } from '../../utils/apiResponse';

export const login = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, role } = LoginSchema.parse(req.body);
    const result = await AuthService.login(email, role);
    created(res, result, 'Login successful');
  } catch (e) { next(e); }
};

export const requestOtp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email } = RequestOtpSchema.parse(req.body);
    const result = await AuthService.requestOtp(email);
    ok(res, result);
  } catch (e) { next(e); }
};

export const verifyOtp = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { email, otp } = VerifyOtpSchema.parse(req.body);
    const result = await AuthService.verifyOtp(email, otp);
    created(res, result, 'Login successful');
  } catch (e) { next(e); }
};

export const refreshToken = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = RefreshTokenSchema.parse(req.body);
    const result = await AuthService.refreshAccessToken(refreshToken);
    ok(res, result);
  } catch (e) { next(e); }
};

export const logout = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { refreshToken } = RefreshTokenSchema.parse(req.body);
    await AuthService.logout(refreshToken);
    ok(res, null, 'Logged out');
  } catch (e) { next(e); }
};
