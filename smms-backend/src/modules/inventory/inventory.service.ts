import { MealSlot, Role } from '../../config/enums';
import { prisma } from '../../config/prisma';
import { CreateInventoryItemInput, UpdateInventoryItemInput } from './inventory.schema';
import { notifyRole } from '../notifications/notifications.service';

// ── List all inventory items ──────────────────────────────────────────────────
export const listInventory = async () =>
  prisma.inventoryItem.findMany({
    include: { mealMappings: true },
    orderBy: { name: 'asc' },
  });

// ── Create item ───────────────────────────────────────────────────────────────
export const createInventoryItem = async (
  userId: string,
  data: CreateInventoryItemInput,
) => {
  return prisma.inventoryItem.create({
    data: {
      name: data.name,
      unit: data.unit,
      currentStock: data.currentStock,
      lowStockLevel: data.lowStockLevel,
      lastEditedById: userId,
      mealMappings: data.mealMappings
        ? { create: data.mealMappings }
        : undefined,
    },
    include: { mealMappings: true },
  });
};

// ── Update item (stock adjustment or mapping change) ─────────────────────────
export const updateInventoryItem = async (
  id: string,
  userId: string,
  data: UpdateInventoryItemInput,
) => {
  const item = await prisma.inventoryItem.findUnique({ where: { id } });
  if (!item) throw new Error('Inventory item not found');

  // eslint-disable-next-line @typescript-eslint/no-explicit-any
  return prisma.$transaction(async (tx: any) => {
    if (data.mealMappings !== undefined) {
      await tx.inventoryMealMapping.deleteMany({ where: { inventoryItemId: id } });
      for (const m of data.mealMappings) {
        await tx.inventoryMealMapping.create({
          data: { inventoryItemId: id, mealSlot: m.mealSlot, portionQty: m.portionQty },
        });
      }
    }
    return tx.inventoryItem.update({
      where: { id },
      data: {
        ...(data.currentStock !== undefined && { currentStock: data.currentStock }),
        ...(data.lowStockLevel !== undefined && { lowStockLevel: data.lowStockLevel }),
        lastEditedById: userId,
      },
      include: { mealMappings: true },
    });
  });
};

// ── Auto-decrement on attendance (called inside QR transaction) ───────────────
// eslint-disable-next-line @typescript-eslint/no-explicit-any
export const decrementInventoryForMeal = async (mealSlot: string, tx: any) => {
  const mappings = await tx.inventoryMealMapping.findMany({
    where: { mealSlot },
    include: { inventoryItem: true },
  });

  for (const mapping of mappings) {
    const updated = await tx.inventoryItem.update({
      where: { id: mapping.inventoryItemId },
      data: { currentStock: { decrement: mapping.portionQty } },
    });

    if (updated.currentStock <= updated.lowStockLevel) {
      setImmediate(() => {
        notifyRole(Role.ADMIN, {
          title: '⚠️ Low Stock Alert',
          body: `${updated.name} is running low: ${updated.currentStock.toFixed(2)} ${updated.unit} remaining.`,
        }).catch(() => { /* silent */ });
      });
    }
  }
};
