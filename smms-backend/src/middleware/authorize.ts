import { Request, Response, NextFunction } from 'express';
import { forbidden } from '../utils/apiResponse';
import { Role } from '../config/enums';

/**
 * Role guard factory.
 * Usage: router.get('/admin/users', authenticate, authorize(Role.ADMIN), handler)
 */
export const authorize =
  (...allowedRoles: Role[]) =>
  (req: Request, res: Response, next: NextFunction): void => {
    if (!req.user || !allowedRoles.includes(req.user.role)) {
      forbidden(res, 'You do not have permission to access this resource');
      return;
    }
    next();
  };
