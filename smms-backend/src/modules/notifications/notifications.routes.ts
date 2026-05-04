import { Router } from 'express';
import * as NotificationsController from './notifications.controller';
import { authenticate } from '../../middleware/authenticate';

const router = Router();

// All authenticated roles can access notifications
router.get('/',              authenticate, NotificationsController.getMyNotifications);
router.patch('/:id/read',    authenticate, NotificationsController.markRead);
router.patch('/read-all',    authenticate, NotificationsController.markAllRead);

export default router;
