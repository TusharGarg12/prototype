import { Router } from 'express';
import * as AttendanceController from './attendance.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// GET /api/attendance/me  — Student's own history
router.get('/me',        authenticate, AttendanceController.getMyAttendance);

// GET /api/attendance    — Admin filtered view
router.get('/',          authenticate, authorize(Role.ADMIN), AttendanceController.getAdminAttendance);

// GET /api/attendance/footfall  — Admin/Kitchen footfall summary by slot
router.get('/footfall',  authenticate, authorize(Role.ADMIN, Role.KITCHEN_STAFF), AttendanceController.getFootfallSummary);

export default router;
