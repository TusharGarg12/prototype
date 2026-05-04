import { Request, Response, NextFunction } from 'express';
import * as LeavesService from './leaves.service';
import { CreateLeaveSchema, ReviewLeaveSchema, LeaveQuerySchema } from './leaves.schema';
import { ok, created } from '../../utils/apiResponse';

export const createLeave = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = CreateLeaveSchema.parse(req.body);
    created(res, await LeavesService.createLeave(req.user!.userId, data), 'Leave request submitted');
  } catch (e) { next(e); }
};

export const getMyLeaves = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = LeaveQuerySchema.parse(req.query);
    ok(res, await LeavesService.getMyLeaves(req.user!.userId, query));
  } catch (e) { next(e); }
};

export const cancelLeave = async (req: Request, res: Response, next: NextFunction) => {
  try {
    ok(res, await LeavesService.cancelLeave(req.user!.userId, req.params.id), 'Leave cancelled');
  } catch (e) { next(e); }
};

export const adminListLeaves = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = LeaveQuerySchema.parse(req.query);
    ok(res, await LeavesService.adminListLeaves(query));
  } catch (e) { next(e); }
};

export const reviewLeave = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = ReviewLeaveSchema.parse(req.body);
    ok(res, await LeavesService.reviewLeave(req.user!.userId, req.params.id, data));
  } catch (e) { next(e); }
};
