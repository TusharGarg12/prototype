import { prisma } from '../../config/prisma';
import { CreateDishInput, UpdateDishInput } from './dishes.schema';

export const listDishes = async (activeOnly = true) =>
  prisma.dish.findMany({
    where: activeOnly ? { isActive: true } : {},
    orderBy: { name: 'asc' },
  });

export const getDish = async (id: string) => {
  const dish = await prisma.dish.findUnique({ where: { id } });
  if (!dish) throw new Error('Dish not found');
  return dish;
};

export const createDish = async (data: CreateDishInput) =>
  prisma.dish.create({ data });

export const updateDish = async (id: string, data: UpdateDishInput) => {
  const dish = await prisma.dish.findUnique({ where: { id } });
  if (!dish) throw new Error('Dish not found');
  return prisma.dish.update({ where: { id }, data });
};

export const deleteDish = async (id: string) => {
  const dish = await prisma.dish.findUnique({ where: { id } });
  if (!dish) throw new Error('Dish not found');
  // Soft-delete: deactivate instead of physical delete
  return prisma.dish.update({ where: { id }, data: { isActive: false } });
};
