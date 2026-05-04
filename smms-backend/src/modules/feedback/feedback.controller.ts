import { Request, Response, NextFunction } from 'express';
import * as FeedbackService from './feedback.service';
import { CreateFeedbackSchema, FeedbackQuerySchema } from './feedback.schema';
import { ok, created } from '../../utils/apiResponse';

export const createFeedback = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = CreateFeedbackSchema.parse(req.body);
    created(res, await FeedbackService.createFeedback(req.user!.userId, data), 'Feedback submitted');
  } catch (e) { next(e); }
};

export const adminListFeedback = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = FeedbackQuerySchema.parse(req.query);
    ok(res, await FeedbackService.adminListFeedback(query));
  } catch (e) { next(e); }
};

export const getRatingSummary = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const date = (req.query.date as string) ?? new Date().toISOString().split('T')[0];
    ok(res, await FeedbackService.getRatingSummary(date));
  } catch (e) { next(e); }
};
