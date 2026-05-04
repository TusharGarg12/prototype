import { Request, Response, NextFunction } from 'express';
import { ok } from '../../utils/apiResponse';
import { z } from 'zod';
import * as ChatbotService from './chatbot.service';

const AskSchema = z.object({
  message: z.string().min(1),
});

export const ask = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const { message } = AskSchema.parse(req.body);
    const result = await ChatbotService.answerQuestion(message);
    ok(res, result, 'Chatbot reply');
  } catch (e) {
    next(e);
  }
};
