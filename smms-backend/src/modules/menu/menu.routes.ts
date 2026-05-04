import { Router } from 'express';
import * as MenuController from './menu.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// ── Student + all authenticated ───────────────────────────────────────────────
router.get('/today',   authenticate, MenuController.getTodayMenu);
router.get('/week',    authenticate, MenuController.getWeeklyMenu);

// ── Admin ─────────────────────────────────────────────────────────────────────
router.get('/',        authenticate, authorize(Role.ADMIN), MenuController.queryMenus);
router.post('/',       authenticate, authorize(Role.ADMIN), MenuController.createMenu);
router.patch('/:id',   authenticate, authorize(Role.ADMIN), MenuController.updateMenu);
router.delete('/:id',  authenticate, authorize(Role.ADMIN), MenuController.deleteMenu);

export default router;
