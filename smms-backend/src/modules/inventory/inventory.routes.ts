import { Router } from 'express';
import * as InventoryController from './inventory.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// ── Admin + Kitchen Staff can view ────────────────────────────────────────────
router.get('/',         authenticate, authorize(Role.ADMIN, Role.KITCHEN_STAFF), InventoryController.listInventory);

// ── Admin only can mutate ─────────────────────────────────────────────────────
router.post('/',        authenticate, authorize(Role.ADMIN), InventoryController.createInventoryItem);
router.patch('/:id',    authenticate, authorize(Role.ADMIN), InventoryController.updateInventoryItem);

export default router;
