import { Request, Response, NextFunction } from 'express';
import { verifyAccessToken } from '../utils/jwt';
import { unauthorized } from '../utils/apiResponse';
import { Role } from '../config/enums';

// Extend Express Request to carry the decoded token payload
declare global {
  namespace Express {
    interface Request {
      user?: { userId: string; role: Role };
    }
  }
}

export const authenticate = (req: Request, res: Response, next: NextFunction): void => {
  const authHeader = req.headers.authorization;

  if (!authHeader?.startsWith('Bearer ')) {
    unauthorized(res, 'Missing or malformed Authorization header');
    return;
  }

  const token = authHeader.split(' ')[1];

  try {
    const payload = verifyAccessToken(token);
    req.user = { userId: payload.userId, role: payload.role as Role };
    next();
  } catch {
    unauthorized(res, 'Invalid or expired access token');
  }
};
