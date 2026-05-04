import { Router } from 'express';
import * as UsersController from './users.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// ── Student ───────────────────────────────────────────────────────────────────
router.get('/me',         authenticate, UsersController.getMe);
router.patch('/me',       authenticate, UsersController.updateMe);

// ── Admin ─────────────────────────────────────────────────────────────────────
router.get('/',           authenticate, authorize(Role.ADMIN), UsersController.listUsers);
router.post('/',          authenticate, authorize(Role.ADMIN), UsersController.createUser);
router.patch('/:id',      authenticate, authorize(Role.ADMIN), UsersController.adminUpdateUser);

export default router;
