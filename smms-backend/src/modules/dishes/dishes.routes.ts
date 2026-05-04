import { Router } from 'express';
import * as DishesController from './dishes.controller';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';

const router = Router();

// ── All authenticated ─────────────────────────────────────────────────────────
router.get('/',        authenticate, DishesController.listDishes);
router.get('/:id',     authenticate, DishesController.getDish);

// ── Admin ─────────────────────────────────────────────────────────────────────
router.post('/',       authenticate, authorize(Role.ADMIN), DishesController.createDish);
router.patch('/:id',   authenticate, authorize(Role.ADMIN), DishesController.updateDish);
router.delete('/:id',  authenticate, authorize(Role.ADMIN), DishesController.deleteDish);

export default router;
