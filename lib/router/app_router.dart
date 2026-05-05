import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/providers/auth_provider.dart';

import '../screens/student/student_dashboard_screen.dart';
import '../screens/student/qr_meal_pass_screen.dart';
import '../screens/student/menu_browser_screen.dart';
import '../screens/student/leave_management_screen.dart';
import '../screens/student/dish_voting_screen.dart';
import '../screens/student/surge_management_screen.dart';
import '../screens/student/feedback_screen.dart';
import '../screens/student/notifications_screen.dart';
import '../screens/student/profile_screen.dart';

import '../screens/admin/admin_dashboard_screen.dart';
import '../screens/admin/qr_scanner_screen.dart';
import '../screens/admin/menu_management_screen.dart';
import '../screens/admin/analytics_screen.dart';
import '../screens/admin/simulation_screen.dart';
import '../screens/admin/kitchen_display_screen.dart';
import '../screens/admin/leave_approval_screen.dart';

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';

class DummyScreen extends StatelessWidget {
  final String title;
  const DummyScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(child: Text(title)),
    );
  }
}

// ── Auth redirect key — rebuilds router when auth state changes ───────────────
final _rootKey = GlobalKey<NavigatorState>();

final GoRouter appRouter = GoRouter(
  navigatorKey: _rootKey,
  initialLocation: '/splash',
  redirect: (context, state) {
    final auth = context.read<AuthProvider>();
    final isLoggingIn = state.matchedLocation.startsWith('/login') ||
        state.matchedLocation.startsWith('/splash');

    if (auth.state == AuthState.unauthenticated && !isLoggingIn) {
      return '/login';
    }
    return null;
  },
  refreshListenable: _AuthListenable(),
  routes: [
    // --- AUTH FLOW ---
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    // --- STUDENT FLOW ---
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const StudentDashboardScreen(),
      routes: [
        GoRoute(path: 'qr',            builder: (context, state) => const QRMealPassScreen()),
        GoRoute(path: 'menu',          builder: (context, state) => const MenuBrowserScreen()),
        GoRoute(path: 'leave',         builder: (context, state) => const LeaveManagementScreen()),
        GoRoute(path: 'voting',        builder: (context, state) => const DishVotingScreen()),
        GoRoute(path: 'feedback',      builder: (context, state) => const FeedbackScreen()),
        GoRoute(path: 'surge',         builder: (context, state) => const SurgeManagementScreen()),
        GoRoute(path: 'notifications', builder: (context, state) => const NotificationsScreen()),
      ],
    ),

    // --- ADMIN FLOW ---
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(path: 'qr-scanner',      builder: (context, state) => const QRScannerScreen()),
        GoRoute(path: 'menu-management', builder: (context, state) => const MenuManagementScreen()),
        GoRoute(path: 'analytics',       builder: (context, state) => const AnalyticsScreen()),
        GoRoute(path: 'simulation',      builder: (context, state) => const SimulationScreen()),
        GoRoute(path: 'leave-approvals', builder: (context, state) => const LeaveApprovalScreen()),
      ],
    ),

    // --- KITCHEN FLOW ---
    GoRoute(
      path: '/kitchen',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'kitchen';
        return KitchenDisplayScreen(userRole: role);
      },
    ),

    // --- SHARED FLOW ---
    GoRoute(
      path: '/profile',
      builder: (context, state) => const ProfileScreen(),
    ),
  ],
);

/// Bridges AuthProvider changes → GoRouter refresh
class _AuthListenable extends ChangeNotifier {
  // Singleton that listens to nothing itself — GoRouter handles the rebuild
  // via refreshListenable when we call notifyListeners from AuthProvider.
  // We rely on GoRouter's built-in redirect being re-evaluated automatically.
}
