import 'package:flutter/foundation.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState { unknown, unauthenticated, authenticated }

class AuthProvider extends ChangeNotifier {
  AuthState _state = AuthState.unknown;
  UserModel? _user;
  String? _error;
  bool _loading = false;

  AuthState get state   => _state;
  UserModel? get user   => _user;
  String? get error     => _error;
  bool get loading      => _loading;
  bool get isLoggedIn   => _state == AuthState.authenticated;

  // ── Restore session on app start ─────────────────────────────────────────
  Future<void> restoreSession() async {
    final stored = await authService.getStoredUser();
    if (stored != null && await authService.isLoggedIn()) {
      _user  = stored;
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  // ── Request OTP ──────────────────────────────────────────────────────────
  Future<bool> requestOtp(String email) async {
    _setLoading(true);
    try {
      await authService.requestOtp(email);
      _clearError();
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Verify OTP ────────────────────────────────────────────────────────────
  Future<bool> verifyOtp(String email, String otp) async {
    _setLoading(true);
    try {
      final user = await authService.verifyOtp(email, otp);
      _user  = user;
      _state = AuthState.authenticated;
      _clearError();
      notifyListeners();
      return true;
    } catch (e) {
      _setError(_friendlyError(e));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  // Refresh Profile
  Future<void> refreshProfile() async {
    try {
      final updatedUser = await authService.getMe();
      _user = updatedUser;
      notifyListeners();
    } catch (_) {}
  }

  Future<void> logout() async {
    await authService.logout();
    _user  = null;
    _state = AuthState.unauthenticated;
    _clearError();
    notifyListeners();
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  void _setLoading(bool v) { _loading = v; notifyListeners(); }
  void _setError(String msg) { _error = msg; notifyListeners(); }
  void _clearError() { _error = null; }

  String _friendlyError(Object e) {
    final msg = e.toString();
    if (msg.contains('404') || msg.contains('not found')) return 'User not found. Please check your email.';
    if (msg.contains('401') || msg.contains('Invalid')) return 'Invalid OTP. Please try again.';
    if (msg.contains('SocketException') || msg.contains('connection')) return 'Cannot reach server. Check your connection.';
    return 'Something went wrong. Please try again.';
  }
}
