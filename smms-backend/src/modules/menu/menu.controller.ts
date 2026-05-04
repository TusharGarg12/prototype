import { Request, Response, NextFunction } from 'express';
import * as MenuService from './menu.service';
import { CreateMenuSchema, UpdateMenuSchema, MenuQuerySchema } from './menu.schema';
import { ok, created } from '../../utils/apiResponse';

export const getTodayMenu = async (_req: Request, res: Response, next: NextFunction) => {
  try { ok(res, await MenuService.getTodayMenu()); }
  catch (e) { next(e); }
};

export const getWeeklyMenu = async (_req: Request, res: Response, next: NextFunction) => {
  try { ok(res, await MenuService.getWeeklyMenu()); }
  catch (e) { next(e); }
};

export const createMenu = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = CreateMenuSchema.parse(req.body);
    const menu = await MenuService.createMenu(req.user!.userId, data);
    created(res, menu, 'Menu created');
  } catch (e) { next(e); }
};

export const updateMenu = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = UpdateMenuSchema.parse(req.body);
    const menu = await MenuService.updateMenu(req.params.id, data);
    ok(res, menu);
  } catch (e) { next(e); }
};

export const deleteMenu = async (req: Request, res: Response, next: NextFunction) => {
  try {
    await MenuService.deleteMenu(req.params.id);
    ok(res, null, 'Menu deleted');
  } catch (e) { next(e); }
};

export const queryMenus = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const query = MenuQuerySchema.parse(req.query);
    ok(res, await MenuService.queryMenus(query));
  } catch (e) { next(e); }
};
