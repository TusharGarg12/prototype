import { Request, Response, NextFunction } from 'express';
import * as DishesService from './dishes.service';
import { CreateDishSchema, UpdateDishSchema } from './dishes.schema';
import { ok, created } from '../../utils/apiResponse';

export const listDishes = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const activeOnly = req.query.activeOnly !== 'false';
    ok(res, await DishesService.listDishes(activeOnly));
  } catch (e) { next(e); }
};

export const getDish = async (req: Request, res: Response, next: NextFunction) => {
  try { ok(res, await DishesService.getDish(req.params.id)); }
  catch (e) { next(e); }
};

export const createDish = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = CreateDishSchema.parse(req.body);
    created(res, await DishesService.createDish(data), 'Dish created');
  } catch (e) { next(e); }
};

export const updateDish = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = UpdateDishSchema.parse(req.body);
    ok(res, await DishesService.updateDish(req.params.id, data));
  } catch (e) { next(e); }
};

export const deleteDish = async (req: Request, res: Response, next: NextFunction) => {
  try {
    ok(res, await DishesService.deleteDish(req.params.id), 'Dish deactivated');
  } catch (e) { next(e); }
};
