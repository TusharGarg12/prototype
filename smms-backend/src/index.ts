import 'dotenv/config';
import './config/env'; // validate env before anything else
import express from 'express';
import helmet from 'helmet';
import cors from 'cors';
import morgan from 'morgan';
import rateLimit from 'express-rate-limit';

import { env } from './config/env';
import { errorHandler } from './middleware/errorHandler';

import authRoutes         from './modules/auth/auth.routes';
import usersRoutes        from './modules/users/users.routes';
import qrRoutes           from './modules/qr/qr.routes';
import attendanceRoutes   from './modules/attendance/attendance.routes';
import menuRoutes         from './modules/menu/menu.routes';
import dishesRoutes       from './modules/dishes/dishes.routes';
import leavesRoutes       from './modules/leaves/leaves.routes';
import feedbackRoutes     from './modules/feedback/feedback.routes';
import inventoryRoutes    from './modules/inventory/inventory.routes';
import notificationsRoutes from './modules/notifications/notifications.routes';
import analyticsRoutes    from './modules/analytics/analytics.routes';
import optimizationRoutes from './modules/optimization/optimization.routes';

const app = express();

// ── Global Middleware ─────────────────────────────────────────────────────────
app.use(helmet());
app.use(cors({ origin: '*' })); // tighten in production
app.use(express.json());
app.use(morgan(env.NODE_ENV === 'development' ? 'dev' : 'combined'));

// Rate limiter — protect auth endpoints
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 min
  max: 20,
  message: { success: false, error: 'Too many requests, please try again later' },
});

// ── Health Check ──────────────────────────────────────────────────────────────
app.get('/health', (_req, res) => res.json({ status: 'ok', env: env.NODE_ENV }));

// ── API Routes ────────────────────────────────────────────────────────────────
app.use('/api/auth',          authLimiter, authRoutes);
app.use('/api/users',         usersRoutes);
app.use('/api/qr',            qrRoutes);
app.use('/api/attendance',    attendanceRoutes);
app.use('/api/menu',          menuRoutes);
app.use('/api/dishes',        dishesRoutes);
app.use('/api/leaves',        leavesRoutes);
app.use('/api/feedback',      feedbackRoutes);
app.use('/api/inventory',     inventoryRoutes);
app.use('/api/notifications', notificationsRoutes);
app.use('/api/analytics',     analyticsRoutes);
app.use('/api/optimization',   optimizationRoutes);

// ── 404 Handler ───────────────────────────────────────────────────────────────
app.use((_req, res) => {
  res.status(404).json({ success: false, error: 'Route not found' });
});

// ── Global Error Handler ──────────────────────────────────────────────────────
app.use(errorHandler);

// ── Start Server ──────────────────────────────────────────────────────────────
app.listen(env.PORT, () => {
  console.log(`\n🚀 SMMS Backend running on http://localhost:${env.PORT}`);
  console.log(`📋 Environment: ${env.NODE_ENV}\n`);
});

export default app;
