import { prisma } from '../../config/prisma';
import {
  signAccessToken,
  generateRefreshToken,
  hashRefreshToken,
} from '../../utils/jwt';
import { env } from '../../config/env';
import { Role } from '../../config/enums';

const REFRESH_EXPIRY_DAYS = 7;

const issueTokensForUser = async (user: { id: string; email: string; name: string | null; role: string; rewardPoints: number }) => {
  const accessToken = signAccessToken({ userId: user.id, role: user.role as Role });
  const { raw: refreshToken, hashed } = generateRefreshToken();
  const expiresAt = new Date(Date.now() + REFRESH_EXPIRY_DAYS * 24 * 60 * 60 * 1000);

  await prisma.refreshToken.create({
    data: { userId: user.id, token: hashed, expiresAt },
  });

  return {
    accessToken,
    refreshToken,
    user: {
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
      rewardPoints: user.rewardPoints,
    },
  };
};

// ── Direct login ──────────────────────────────────────────────────────────────
export const login = async (email: string, role: string) => {
  let user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    user = await prisma.user.create({
      data: { email, name: email.split('@')[0], role: role as Role },
    });
  } else if (user.role !== role) {
    user = await prisma.user.update({
      where: { email },
      data: { role: role as Role },
    });
  }

  if (!user.isActive) throw new Error('Account is deactivated');
  return issueTokensForUser(user);
};

// ── Request OTP ───────────────────────────────────────────────────────────────
export const requestOtp = async (email: string) => {
  let user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    user = await prisma.user.create({
      data: { email, name: email.split('@')[0], role: Role.STUDENT },
    });
  }

  if (!user.isActive) throw new Error('Account is deactivated');
  return { message: 'OTP login is disabled. Use direct login instead.' };
};

// ── Verify OTP ────────────────────────────────────────────────────────────────
export const verifyOtp = async (email: string, otp: string) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new Error('User not found');
  if (!user.isActive) throw new Error('Account is deactivated');
  return issueTokensForUser(user);
};

// ── Refresh Access Token ──────────────────────────────────────────────────────
export const refreshAccessToken = async (rawToken: string) => {
  const hashed = hashRefreshToken(rawToken);

  const record = await prisma.refreshToken.findUnique({ where: { token: hashed } });
  if (!record || record.revoked || record.expiresAt < new Date()) {
    throw new Error('Refresh token not found or revoked');
  }

  const user = await prisma.user.findUnique({ where: { id: record.userId } });
  if (!user || !user.isActive) throw new Error('User not found');

  const accessToken = signAccessToken({ userId: user.id, role: user.role as Role });
  return { accessToken };
};

// ── Logout ────────────────────────────────────────────────────────────────────
export const logout = async (rawToken: string) => {
  const hashed = hashRefreshToken(rawToken);
  await prisma.refreshToken.updateMany({
    where: { token: hashed },
    data: { revoked: true },
  });
};
