import { Router } from 'express';
import * as LeavesController from './leaves.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// ── Student ───────────────────────────────────────────────────────────────────
router.post('/',                authenticate, authorize(Role.STUDENT), LeavesController.createLeave);
router.get('/me',               authenticate, authorize(Role.STUDENT), LeavesController.getMyLeaves);
router.patch('/me/:id/cancel',  authenticate, authorize(Role.STUDENT), LeavesController.cancelLeave);

// ── Admin ─────────────────────────────────────────────────────────────────────
router.get('/',                 authenticate, authorize(Role.ADMIN), LeavesController.adminListLeaves);
router.patch('/:id/review',     authenticate, authorize(Role.ADMIN), LeavesController.reviewLeave);

export default router;
