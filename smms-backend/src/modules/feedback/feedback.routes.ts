import { Router } from 'express';
import * as FeedbackController from './feedback.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// ── Student ───────────────────────────────────────────────────────────────────
router.post('/',         authenticate, authorize(Role.STUDENT), FeedbackController.createFeedback);

// ── Admin ─────────────────────────────────────────────────────────────────────
router.get('/',          authenticate, authorize(Role.ADMIN), FeedbackController.adminListFeedback);
router.get('/summary',   authenticate, authorize(Role.ADMIN), FeedbackController.getRatingSummary);

export default router;
