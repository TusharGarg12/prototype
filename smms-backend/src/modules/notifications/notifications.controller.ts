import { Request, Response, NextFunction } from 'express';
import * as NotificationsService from './notifications.service';
import { NotificationQuerySchema } from './notifications.schema';
import { ok } from '../../utils/apiResponse';

export const getMyNotifications = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = NotificationQuerySchema.parse(req.query);
    ok(res, await NotificationsService.getMyNotifications(req.user!.userId, query));
  } catch (e) { next(e); }
};

export const markRead = async (req: Request, res: Response, next: NextFunction) => {
  try {
    ok(res, await NotificationsService.markRead(req.user!.userId, req.params.id), 'Marked as read');
  } catch (e) { next(e); }
};

export const markAllRead = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await NotificationsService.markAllRead(req.user!.userId);
    ok(res, null, 'All notifications marked as read');
  } catch (e) { next(e); }
};
