import { Request, Response, NextFunction } from 'express';
import * as UsersService from './users.service';
import { UpdateMeSchema, CreateUserSchema, AdminUpdateUserSchema } from './users.schema';
import { ok, created } from '../../utils/apiResponse';
import { z } from 'zod';
import { Role } from '../../config/enums';

export const getMe = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const user = await UsersService.getMe(req.user!.userId);
    ok(res, user);
  } catch (e) { next(e); }
};

export const updateMe = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = UpdateMeSchema.parse(req.body);
    const user = await UsersService.updateMe(req.user!.userId, data);
    ok(res, user);
  } catch (e) { next(e); }
};

export const listUsers = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const page = z.coerce.number().positive().default(1).parse(req.query.page);
    const limit = z.coerce.number().positive().max(100).default(20).parse(req.query.limit);
    const role = req.query.role as Role | undefined;
    const result = await UsersService.listUsers(page, limit, role);
    ok(res, result);
  } catch (e) { next(e); }
};

export const createUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = CreateUserSchema.parse(req.body);
    const user = await UsersService.createUser(data);
    created(res, user, 'User created');
  } catch (e) { next(e); }
};

export const adminUpdateUser = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = AdminUpdateUserSchema.parse(req.body);
    const user = await UsersService.adminUpdateUser(req.params.id, data);
    ok(res, user);
  } catch (e) { next(e); }
};
