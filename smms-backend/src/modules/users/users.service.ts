import { prisma } from '../../config/prisma';
import { CreateUserInput, UpdateMeInput, AdminUpdateUserInput } from './users.schema';
import { Role } from '../../config/enums';

// ── Get self ──────────────────────────────────────────────────────────────────
export const getMe = async (userId: string) => {
  const user = await prisma.user.findUnique({
    where: { id: userId },
    select: {
      id: true, name: true, email: true, role: true,
      rollNumber: true, photoUrl: true, isActive: true, 
      rewardPoints: true, createdAt: true,
    },
  });
  if (!user) throw new Error('User not found');
  return user;
};

// ── Update self ───────────────────────────────────────────────────────────────
export const updateMe = async (userId: string, data: UpdateMeInput) => {
  return prisma.user.update({
    where: { id: userId },
    data,
    select: {
      id: true, name: true, email: true, role: true,
      rollNumber: true, photoUrl: true,
    },
  });
};

// ── Admin: list all users ─────────────────────────────────────────────────────
export const listUsers = async (page: number, limit: number, role?: Role) => {
  const where = role ? { role } : {};
  const [users, total] = await Promise.all([
    prisma.user.findMany({
      where,
      skip: (page - 1) * limit,
      take: limit,
      orderBy: { createdAt: 'desc' },
      select: {
        id: true, name: true, email: true, role: true,
        rollNumber: true, isActive: true, createdAt: true,
      },
    }),
    prisma.user.count({ where }),
  ]);
  return { users, total, page, limit };
};

// ── Admin: create user ────────────────────────────────────────────────────────
export const createUser = async (data: CreateUserInput) => {
  return prisma.user.create({
    data,
    select: { id: true, name: true, email: true, role: true, rollNumber: true },
  });
};

// ── Admin: update user ────────────────────────────────────────────────────────
export const adminUpdateUser = async (id: string, data: AdminUpdateUserInput) => {
  const user = await prisma.user.findUnique({ where: { id } });
  if (!user) throw new Error('User not found');
  return prisma.user.update({
    where: { id },
    data,
    select: { id: true, name: true, email: true, role: true, isActive: true },
  });
};
