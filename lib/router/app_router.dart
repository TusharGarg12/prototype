import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

import '../screens/auth/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/otp_verification_screen.dart';

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

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
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
    GoRoute(
      path: '/otp',
      builder: (context, state) {
        final role = state.uri.queryParameters['role'] ?? 'student';
        return OTPVerificationScreen(role: role);
      },
    ),

    // --- STUDENT FLOW ---
    GoRoute(
      path: '/dashboard',
      builder: (context, state) => const StudentDashboardScreen(),
      routes: [
        GoRoute(path: 'qr', builder: (context, state) => const QRMealPassScreen()),
        GoRoute(path: 'menu', builder: (context, state) => const MenuBrowserScreen()),
        GoRoute(path: 'leave', builder: (context, state) => const LeaveManagementScreen()),
        GoRoute(path: 'voting', builder: (context, state) => const DishVotingScreen()),
        GoRoute(path: 'feedback', builder: (context, state) => const FeedbackScreen()),
        GoRoute(path: 'surge', builder: (context, state) => const SurgeManagementScreen()),
        GoRoute(path: 'notifications', builder: (context, state) => const NotificationsScreen()),
      ],
    ),

    // --- ADMIN FLOW ---
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminDashboardScreen(),
      routes: [
        GoRoute(path: 'qr-scanner', builder: (context, state) => const QRScannerScreen()),
        GoRoute(path: 'menu-management', builder: (context, state) => const MenuManagementScreen()),
        GoRoute(path: 'analytics', builder: (context, state) => const AnalyticsScreen()),
        GoRoute(path: 'simulation', builder: (context, state) => const SimulationScreen()),
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
