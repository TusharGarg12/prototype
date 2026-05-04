import { nanoid } from 'nanoid';
import { createHash } from 'crypto';

/**
 * Generate a QR pass token pair.
 * raw   → returned to the client (encoded in the QR image)
 * hashed → SHA-256 digest stored in the database
 *
 * Anti-replay: the raw token is never persisted; even if the DB is
 * compromised, an attacker cannot produce the raw value from the hash.
 */
export const generateQRToken = (): { raw: string; hashed: string } => {
  const raw = nanoid(32);
  const hashed = createHash('sha256').update(raw).digest('hex');
  return { raw, hashed };
};

/** Hash an arbitrary string with SHA-256 (used during QR validation). */
export const hashToken = (raw: string): string =>
  createHash('sha256').update(raw).digest('hex');
