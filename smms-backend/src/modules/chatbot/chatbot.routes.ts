import { Router } from 'express';
import { authenticate } from '../../middleware/authenticate';
import { authorize } from '../../middleware/authorize';
import { Role } from '../../config/enums';
import * as ChatbotController from './chatbot.controller';

const router = Router();

router.post('/ask', authenticate, authorize(Role.STUDENT), ChatbotController.ask);

export default router;
