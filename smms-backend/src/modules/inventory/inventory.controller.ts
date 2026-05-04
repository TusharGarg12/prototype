import { Request, Response, NextFunction } from 'express';
import * as InventoryService from './inventory.service';
import { CreateInventoryItemSchema, UpdateInventoryItemSchema } from './inventory.schema';
import { ok, created } from '../../utils/apiResponse';

export const listInventory = async (_req: Request, res: Response, next: NextFunction) => {
  try { ok(res, await InventoryService.listInventory()); }
  catch (e) { next(e); }
};

export const createInventoryItem = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = CreateInventoryItemSchema.parse(req.body);
    created(res, await InventoryService.createInventoryItem(req.user!.userId, data), 'Item added');
  } catch (e) { next(e); }
};

export const updateInventoryItem = async (req: Request, res: Response, next: NextFunction) => {
  try {
    const data = UpdateInventoryItemSchema.parse(req.body);
    ok(res, await InventoryService.updateInventoryItem(req.params.id, req.user!.userId, data));
  } catch (e) { next(e); }
};
