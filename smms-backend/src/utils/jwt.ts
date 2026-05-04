import jwt from 'jsonwebtoken';
import { nanoid } from 'nanoid';
import { createHash } from 'crypto';
import { env } from '../config/env';
import { Role } from '../config/enums';

export interface AccessTokenPayload {
  userId: string;
  role: Role;
}

// ── Access Token (15 minutes) ────────────────────────────────────────────────
export const signAccessToken = (payload: AccessTokenPayload): string =>
  jwt.sign(payload, env.JWT_ACCESS_SECRET, { expiresIn: '15m' });

export const verifyAccessToken = (token: string): AccessTokenPayload =>
  jwt.verify(token, env.JWT_ACCESS_SECRET) as AccessTokenPayload;

// ── Refresh Token (7 days, stored hashed in DB) ──────────────────────────────
export const generateRefreshToken = (): { raw: string; hashed: string } => {
  const raw = nanoid(64);
  const hashed = createHash('sha256').update(raw).digest('hex');
  return { raw, hashed };
};

export const hashRefreshToken = (raw: string): string =>
  createHash('sha256').update(raw).digest('hex');
