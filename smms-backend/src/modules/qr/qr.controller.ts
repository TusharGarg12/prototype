import { Request, Response, NextFunction } from 'express';
import * as QRService from './qr.service';
import { GenerateQRSchema, ValidateQRSchema, OverrideAttendanceSchema } from './qr.schema';
import { ok, created } from '../../utils/apiResponse';

export const generateQR = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { mealSlot } = GenerateQRSchema.parse(req.body);
    const result = await QRService.generateQRPass(req.user!.userId, mealSlot);
    created(res, result, 'QR pass generated');
  } catch (e) { next(e); }
};

export const validateQR = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { token, counterId } = ValidateQRSchema.parse(req.body);
    const log = await QRService.validateQRPass(token, req.user!.userId, counterId);
    ok(res, log, 'Attendance recorded');
  } catch (e) { next(e); }
};

export const overrideAttendance = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const input = OverrideAttendanceSchema.parse(req.body);
    const log = await QRService.overrideAttendance(req.user!.userId, input);
    created(res, log, 'Override attendance recorded');
  } catch (e) { next(e); }
};
