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
- **Email Delivery:** SMTP delivery is wired through Nodemailer and ready for provider credentials.
- **PostgreSQL Switch:** Prisma is already configured for PostgreSQL; deployment validation remains.

## 🔴 Remaining After Phase 1

These are no longer core MVP blockers; they are the next hardening and expansion steps.

### 1. Production Readiness
- SMTP-based OTP delivery is wired.
- PostgreSQL-backed deployment is configured but still needs a live environment.

### 2. Phase 2 And Beyond
- Predictive analytics is now proxied to the ML backend.
- Surge management and reward incentives are wired into Flutter.
- Simulation / digital twin planning is now backend-backed.
- Chatbot responses are no longer canned-only.
- Weather/calendar-aware menu guidance, leftover routing, ingredient fatigue detection, sustainability estimates, and health-focused menu suggestions are now live through the optimization backend.
- Crowd heatmap visualization still needs polish and UX refinement.
- Multi-mess support, A/B testing, and reusable recipe/template tooling remain open.

---

## ⏭️ Phase 2 & Beyond (Smart Features)
*Now that Phase 1 is in place, the feature set is moving into live phase 2 wiring:*
- **Predictive Analytics:** Footfall prediction by time slot is backed by the ML proxy.
- **Surge Management:** Reward points for eating during off-peak hours are wired into the student screen.
- **Crowd Heatmap:** Visualization is still present, with more refinement left for the admin dashboard.
- **Weather/Calendar Integration:** Menu guidance now adapts to weather and calendar context, including leftover routing and ingredient fatigue hints.
- **Sustainability:** Waste and carbon-saved estimates are now surfaced from optimization guidance.
