import { Response } from 'express';

export interface ApiSuccess<T> {
  success: true;
  data: T;
  message?: string;
}

export interface ApiError {
  success: false;
  error: string;
  details?: unknown;
}

export const ok = <T>(res: Response, data: T, message?: string, statusCode = 200): Response =>
  res.status(statusCode).json({ success: true, data, message } satisfies ApiSuccess<T>);

export const created = <T>(res: Response, data: T, message?: string): Response =>
  ok(res, data, message, 201);

export const fail = (res: Response, error: string, statusCode = 400, details?: unknown): Response =>
  res.status(statusCode).json({ success: false, error, details } satisfies ApiError);

export const unauthorized = (res: Response, error = 'Unauthorized'): Response =>
  fail(res, error, 401);

export const forbidden = (res: Response, error = 'Forbidden'): Response =>
  fail(res, error, 403);

export const notFound = (res: Response, error = 'Not found'): Response =>
  fail(res, error, 404);

export const conflict = (res: Response, error: string): Response =>
  fail(res, error, 409);

export const serverError = (res: Response, error = 'Internal server error'): Response =>
  fail(res, error, 500);
