import { Router } from 'express';
import * as QRController from './qr.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// POST /api/qr/generate  — Student generates their QR pass
router.post('/generate',  authenticate, authorize(Role.STUDENT), QRController.generateQR);

// POST /api/qr/validate  — Admin/Kitchen staff scans and validates a QR code
router.post('/validate',  authenticate, authorize(Role.ADMIN, Role.KITCHEN_STAFF), QRController.validateQR);

// POST /api/qr/override  — Admin manual override for lost card / emergency
router.post('/override',  authenticate, authorize(Role.ADMIN), QRController.overrideAttendance);

export default router;
