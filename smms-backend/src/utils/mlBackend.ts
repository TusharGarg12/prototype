import { env } from '../config/env';

const baseUrl = env.ML_BACKEND_URL.replace(/\/$/, '');

const readJson = async <T>(response: Response): Promise<T> => {
  const payload = await response.json();
  return payload as T;
};

const postJson = async <T>(path: string, body: Record<string, unknown>): Promise<T> => {
  const response = await fetch(`${baseUrl}/api/v1${path}`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(body),
  });

  if (!response.ok) {
    throw new Error(`ML backend request failed: ${response.status}`);
  }

  return readJson<T>(response);
};

export const forecastHeadcount = (body: Record<string, unknown>) => postJson<Record<string, unknown>>('/forecast/headcount', body);
export const optimizeSurge = (body: Record<string, unknown>) => postJson<Record<string, unknown>>('/optimize/surge', body);
export const optimizeWaste = (body: Record<string, unknown>) => postJson<Record<string, unknown>>('/optimize/waste', body);