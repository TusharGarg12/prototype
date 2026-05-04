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

## 🟡 What is LEFT TO BE DONE (Phase 1: Admin & Kitchen Features)

The next immediate phase is wiring the backend to the **Admin** and **Kitchen** Flutter interfaces. The UI files exist, but they need to be connected to the API just like the student screens.

### 1. Admin Flutter Integration
- **QR Scanner Screen:** 
  - Integrate device camera to scan student QR codes.
  - Call `/api/qr/validate` to verify the pass, mark attendance, and auto-decrement inventory.
  - Handle success/failure UI states (e.g., Expired, Already Used, Invalid).
- **Menu Management Screen:**
  - Build UI to create new menus, add/remove dishes, and publish schedules for the week.
- **Leave Approval Inbox (Missing UI/Integration):**
  - Create a screen for admins to view pending student leaves and call API endpoints to Approve/Reject them.
- **Analytics Dashboard:**
  - Fetch footfall data and feedback summaries to display charts/metrics.

### 2. Kitchen Flutter Integration
- **Kitchen Display Screen (KDS):**
  - Fetch and display the live menu for the current meal slot.
  - Show real-time attendance counts to help gauge food preparation speeds.

### 3. Production Readiness & Polish
- **Email Delivery:** Replace the `console.log` mock in `auth.service.ts` with a real SMTP provider (e.g., SendGrid, Nodemailer) to actually email OTPs.
- **PostgreSQL Switch:** Revert the Prisma provider from `sqlite` to `postgresql` and provision a live database for staging/production.

---

## ⏭️ Phase 2 & Beyond (Smart Features)
*Once Phase 1 is fully deployed, the backlog includes:*
- **Predictive Analytics:** Footfall prediction by time slot.
- **Surge Management:** Reward points for eating during off-peak hours.
- **Crowd Heatmap:** Visualizing mess congestion.
- **Weather/Calendar Integration:** Smart menu and inventory suggestions based on external data.
