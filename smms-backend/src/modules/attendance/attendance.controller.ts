import { Request, Response, NextFunction } from 'express';
import * as AttendanceService from './attendance.service';
import { AttendanceQuerySchema } from './attendance.schema';
import { ok } from '../../utils/apiResponse';

export const getMyAttendance = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = AttendanceQuerySchema.parse(req.query);
    const result = await AttendanceService.getMyAttendance(req.user!.userId, query);
    ok(res, result);
  } catch (e) { next(e); }
};

export const getAdminAttendance = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = AttendanceQuerySchema.parse(req.query);
    const result = await AttendanceService.getAdminAttendance(query);
    ok(res, result);
  } catch (e) { next(e); }
};

export const getFootfallSummary = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const date = (req.query.date as string) ?? new Date().toISOString().split('T')[0];
    const result = await AttendanceService.getFootfallSummary(date);
    ok(res, result);
  } catch (e) { next(e); }
};
