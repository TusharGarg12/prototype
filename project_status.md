# SMMS Project Status & Next Steps

This document outlines the current progress against the **Phase 1: MVP** scope defined in the feature plan, and details exactly what remains to be completed.

## 🟢 What is DONE (Phase 1: Core Foundation & Student Features)

We have successfully built the complete backend infrastructure and wired up the entire Student-facing application.

### 1. Backend Architecture & Database
- **Setup:** Node.js, Express, TypeScript, and Prisma ORM.
- **Database:** Fully configured schema (currently using SQLite for instant local dev, production-ready for PostgreSQL).
- **Security:** JWT-based authentication, anti-replay hashed QR tokens, and Role-Based Access Control (RBAC).
- **Seed Data:** Database is pre-populated with users, dishes, menus, and inventory items.

### 2. Core API Modules (Built & Tested)
- **Auth:** OTP request/verify, JWT generation.
- **QR & Attendance:** Time-bound (30 min) pass generation, atomic validation, and automatic inventory deduction upon scan.
- **Menu:** Fetch daily/weekly schedules.
- **Leaves:** Submit and view leave requests.
- **Feedback:** Submit ratings (anonymous or named).
- **Notifications & Inventory:** Low-stock alerts and basic notification fetching.

### 3. Flutter Integration (Student App)
- **State & Networking:** `dio` API client with automatic token refresh, and `provider` for session management.
- **Login Flow:** OTP-based login routing to the correct dashboard based on role.
- **Student Dashboard:** Live greeting, dynamic menu preview, and quick actions.
- **QR Pass Screen:** Live countdown timer and dynamic QR code generation from the API token.
- **Menu Browser:** Weekly fetching with Veg/Non-Veg indicators.
- **Leave Management:** Date-picker implementation and status tracking (Pending/Approved).
- **Feedback & Notifications:** Live submission and reading capabilities.

---

## 🟢 What Is NOW DONE (Phase 1: Admin, Kitchen, and Student MVP)

The Phase 1 MVP is implemented across the Flutter app and backend. The remaining work is now production hardening rather than core Phase 1 feature delivery.

### 1. Admin Flutter Integration
- **QR Scanner Screen:** Implemented with `mobile_scanner`, counter selection, QR validation, and success/failure states.
- **Menu Management Screen:** Implemented with day/slot editing, dish selection, save, and publish flows.
- **Leave Approval Inbox:** Implemented with search, filter, pagination, and approve/reject actions.
- **Analytics Dashboard:** Implemented with footfall, heatmap, ratings, predictions, and summary cards.

### 2. Kitchen Flutter Integration
- **Kitchen Display Screen (KDS):** Implemented with live menu fetching, active meal slot detection, and attendance-based serving indicators.

### 3. Production Readiness & Polish
- **Email Delivery:** Replace the `console.log` mock in `auth.service.ts` with a real SMTP provider (e.g., SendGrid, Nodemailer) to actually email OTPs.
- **PostgreSQL Switch:** Revert the Prisma provider from `sqlite` to `postgresql` and provision a live database for staging/production.

## 🔴 Remaining After Phase 1

These are no longer core MVP blockers; they are the next hardening and expansion steps.

### 1. Production Readiness
- SMTP-based OTP delivery.
- PostgreSQL-backed deployment.

### 2. Phase 2 And Beyond
- Predictive analytics.
- Surge management.
- Crowd heatmap visualization.
- Weather/calendar integration.

---

## ⏭️ Phase 2 & Beyond (Smart Features)
*Now that Phase 1 is in place, the backlog includes:*
- **Predictive Analytics:** Footfall prediction by time slot.
- **Surge Management:** Reward points for eating during off-peak hours.
- **Crowd Heatmap:** Visualizing mess congestion.
- **Weather/Calendar Integration:** Smart menu and inventory suggestions based on external data.
