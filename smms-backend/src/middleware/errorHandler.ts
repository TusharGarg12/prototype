import { Request, Response, NextFunction } from 'express';
import { ZodError } from 'zod';
import { serverError, fail } from '../utils/apiResponse';

export const errorHandler = (
  err: unknown,
  _req: Request,
  res: Response,
  _next: NextFunction,
): void => {
  if (err instanceof ZodError) {
    fail(res, 'Validation error', 422, err.flatten().fieldErrors);
    return;
  }

  if (err instanceof Error) {
    // Known domain errors (thrown as plain Errors with a message)
    const knownMessages = [
      'User not found',
      'OTP expired or not found',
      'Invalid OTP',
      'Refresh token not found or revoked',
      'QR pass not found',
      'QR pass already used',
      'QR pass expired',
      'QR pass blocked',
      'No active meal slot right now',
      'Student already has a meal pass for this slot',
      'Leave request not found',
      'Feedback not found',
      'Menu not found',
      'Dish not found',
      'Inventory item not found',
    ];

    if (knownMessages.includes(err.message)) {
      fail(res, err.message, 400);
      return;
    }

    console.error('[UnhandledError]', err);
    serverError(res, 'An unexpected error occurred');
    return;
  }

  console.error('[UnknownError]', err);
  serverError(res);
};
