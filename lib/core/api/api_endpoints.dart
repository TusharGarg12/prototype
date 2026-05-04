// Base URL — change to your machine's LAN IP when testing on a real device.
// Android emulator uses 10.0.2.2 to reach host localhost.
const String kBaseUrl = 'http://localhost:3000/api';

// ── Auth ───────────────────────────────────────────────────────────────────────
const String kRequestOtp    = '/auth/request-otp';
const String kVerifyOtp     = '/auth/verify-otp';
const String kRefreshToken  = '/auth/refresh';
const String kLogout        = '/auth/logout';

// ── Users ──────────────────────────────────────────────────────────────────────
const String kMe            = '/users/me';
const String kPatchMe       = '/users/me';

// ── Menu ───────────────────────────────────────────────────────────────────────
const String kMenuToday     = '/menu/today';
const String kMenuWeek      = '/menu/week';

// ── QR ─────────────────────────────────────────────────────────────────────────
const String kQrGenerate    = '/qr/generate';
const String kQrValidate    = '/qr/validate';

// ── Attendance ────────────────────────────────────────────────────────────────
const String kAttendanceMe  = '/attendance/me';
const String kFootfall      = '/attendance/footfall';

// ── Leaves ────────────────────────────────────────────────────────────────────
const String kLeaves        = '/leaves';
const String kLeavesMe      = '/leaves/me';

// ── Feedback ──────────────────────────────────────────────────────────────────
const String kFeedback      = '/feedback';

// ── Notifications ──────────────────────────────────────────────────────
const String kNotifications = '/notifications';

// ── Analytics ──────────────────────────────────────────────────────────
const String kAnalyticsHeatmap = '/analytics/heatmap';
const String kAnalyticsPredictions = '/analytics/predictions';
