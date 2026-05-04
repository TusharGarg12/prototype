import { Router } from 'express';
import * as AuthController from './auth.controller';
import { authenticate } from '../../middleware/authenticate';

const router = Router();

// POST /api/auth/request-otp
router.post('/request-otp', AuthController.requestOtp);

// POST /api/auth/verify-otp
router.post('/verify-otp', AuthController.verifyOtp);

// POST /api/auth/refresh
router.post('/refresh', AuthController.refreshToken);

// POST /api/auth/logout  (needs valid refresh token in body)
router.post('/logout', AuthController.logout);

export default router;
