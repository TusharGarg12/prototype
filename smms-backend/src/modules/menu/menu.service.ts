import { prisma } from '../../config/prisma';
import { CreateMenuInput, UpdateMenuInput, MenuQueryInput } from './menu.schema';

// ── Student: today's menu ─────────────────────────────────────────────────────
export const getTodayMenu = async () => {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);

  return prisma.menu.findMany({
    where: { menuDate: today, isPublished: true },
    include: {
      menuItems: {
        include: { dish: true },
      },
    },
    orderBy: { mealSlot: 'asc' },
  });
};

// ── Student: weekly menu ──────────────────────────────────────────────────────
export const getWeeklyMenu = async () => {
  const today = new Date();
  today.setUTCHours(0, 0, 0, 0);
  const weekEnd = new Date(today);
  weekEnd.setUTCDate(weekEnd.getUTCDate() + 6);

  return prisma.menu.findMany({
    where: { menuDate: { gte: today, lte: weekEnd }, isPublished: true },
    include: { menuItems: { include: { dish: true } } },
    orderBy: [{ menuDate: 'asc' }, { mealSlot: 'asc' }],
  });
};

// ── Admin: create menu ────────────────────────────────────────────────────────
export const createMenu = async (createdById: string, data: CreateMenuInput) => {
  const menuDate = new Date(data.menuDate);
  menuDate.setUTCHours(0, 0, 0, 0);

  return prisma.menu.create({
    data: {
      mealSlot: data.mealSlot,
      menuDate,
      isPublished: data.isPublished,
      createdById,
      menuItems: {
        create: data.dishIds.map(dishId => ({ dishId })),
      },
    },
    include: { menuItems: { include: { dish: true } } },
  });
};

// ── Admin: update menu ────────────────────────────────────────────────────────
export const updateMenu = async (id: string, data: UpdateMenuInput) => {
  const menu = await prisma.menu.findUnique({ where: { id } });
  if (!menu) throw new Error('Menu not found');

  return prisma.$transaction(async (tx) => {
    if (data.dishIds !== undefined) {
      // Replace all menu items
      await tx.menuItem.deleteMany({ where: { menuId: id } });
      for (const dishId of data.dishIds) {
        await tx.menuItem.create({ data: { menuId: id, dishId } });
      }
    }

    return tx.menu.update({
      where: { id },
      data: { isPublished: data.isPublished },
      include: { menuItems: { include: { dish: true } } },
    });
  });
};

// ── Admin: delete menu ────────────────────────────────────────────────────────
export const deleteMenu = async (id: string) => {
  const menu = await prisma.menu.findUnique({ where: { id } });
  if (!menu) throw new Error('Menu not found');
  await prisma.menu.delete({ where: { id } });
};

// ── Admin: query menus ────────────────────────────────────────────────────────
export const queryMenus = async (query: MenuQueryInput) => {
  const where: Record<string, unknown> = {};
  if (query.mealSlot) where.mealSlot = query.mealSlot;
  if (query.date) {
    const d = new Date(query.date);
    d.setUTCHours(0, 0, 0, 0);
    where.menuDate = d;
  }

  return prisma.menu.findMany({
    where,
    include: { menuItems: { include: { dish: true } } },
    orderBy: [{ menuDate: 'asc' }, { mealSlot: 'asc' }],
  });
};
