import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import * as OptimizationController from './optimization.controller';

const router = Router();

router.post('/surge', authenticate, OptimizationController.getSurgeRecommendation);
router.post('/waste', authenticate, OptimizationController.getWasteRecommendation);
router.post('/menu-guidance', authenticate, OptimizationController.getMenuGuidance);

export default router;