import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';
import * as AnalyticsController from './analytics.controller';

const router = Router();

router.get('/heatmap', authenticate, authorize(Role.ADMIN), AnalyticsController.getCrowdHeatmap);

export default router;