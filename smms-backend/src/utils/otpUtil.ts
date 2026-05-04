import bcrypt from 'bcryptjs';

const SALT_ROUNDS = 10;

/** Generate a cryptographically random 6-digit OTP string. */
export const generateOtp = (): string =>
  Math.floor(100_000 + Math.random() * 900_000).toString();

/** Hash an OTP for safe storage in the database. */
export const hashOtp = (otp: string): Promise<string> =>
  bcrypt.hash(otp, SALT_ROUNDS);

/** Compare a plain-text OTP against the stored bcrypt hash. */
export const compareOtp = (otp: string, hash: string): Promise<boolean> =>
  bcrypt.compare(otp, hash);
