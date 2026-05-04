import { prisma } from '../../config/prisma';
import { generateOtp, hashOtp, compareOtp } from '../../utils/otpUtil';
import { sendOtpEmail } from '../../utils/mailer';
import {
  signAccessToken,
  generateRefreshToken,
  hashRefreshToken,
} from '../../utils/jwt';
import { env } from '../../config/env';
import { Role } from '../../config/enums';

const REFRESH_EXPIRY_DAYS = 7;

// ── Request OTP ───────────────────────────────────────────────────────────────
export const requestOtp = async (email: string) => {
  // Auto-provision user on first login (college email = identity)
  let user = await prisma.user.findUnique({ where: { email } });
  if (!user) {
    user = await prisma.user.create({
      data: { email, name: email.split('@')[0], role: Role.STUDENT },
    });
  }

  if (!user.isActive) throw new Error('Account is deactivated');

  // Invalidate all previous unused OTPs for this user
  await prisma.otpRecord.updateMany({
    where: { userId: user.id, used: false },
    data: { used: true },
  });

  const otp = generateOtp();
  const hashedOtp = await hashOtp(otp);
  const expiresAt = new Date(
    Date.now() + env.OTP_EXPIRY_MINUTES * 60 * 1000,
  );

  await prisma.otpRecord.create({
    data: { userId: user.id, otp: hashedOtp, expiresAt },
  });

  // ── Send Email via SMTP ──────────
  await sendOtpEmail(email, otp);
  // Log locally just in case for dev server readability (optional)
  if (process.env.NODE_ENV === 'development') {
    console.log(`\n[OTP DEBUG] ✉️  To: ${email}  |  OTP: ${otp}  |  Expires in ${env.OTP_EXPIRY_MINUTES} min\n`);
  }

  return { message: 'OTP sent to email' };
};

// ── Verify OTP ────────────────────────────────────────────────────────────────
export const verifyOtp = async (email: string, otp: string) => {
  const user = await prisma.user.findUnique({ where: { email } });
  if (!user) throw new Error('User not found');
  if (!user.isActive) throw new Error('Account is deactivated');

  const record = await prisma.otpRecord.findFirst({
    where: {
      userId: user.id,
      used: false,
      expiresAt: { gt: new Date() },
    },
    orderBy: { createdAt: 'desc' },
  });
  if (!record) throw new Error('OTP expired or not found');

  const valid = await compareOtp(otp, record.otp);
  if (!valid) throw new Error('Invalid OTP');

  // Mark OTP as consumed
  await prisma.otpRecord.update({
    where: { id: record.id },
    data: { used: true },
  });

  const accessToken = signAccessToken({ userId: user.id, role: user.role as Role });
  const { raw: refreshToken, hashed } = generateRefreshToken();

  const expiresAt = new Date(
    Date.now() + REFRESH_EXPIRY_DAYS * 24 * 60 * 60 * 1000,
  );
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
