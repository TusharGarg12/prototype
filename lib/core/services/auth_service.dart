import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../api/api_client.dart';
import '../api/api_endpoints.dart';
import '../models/user_model.dart';

class AuthService {
  AuthService._();
  static final AuthService instance = AuthService._();

  // ── Request OTP ──────────────────────────────────────────────────────────
  Future<void> requestOtp(String email) async {
    await api.post(kRequestOtp, body: {'email': email});
  }

  // ── Verify OTP → store tokens → return user ───────────────────────────────
  Future<UserModel> verifyOtp(String email, String otp) async {
    final data = await api.post(kVerifyOtp, body: {'email': email, 'otp': otp});
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('access_token',  data['accessToken'] as String);
    await prefs.setString('refresh_token', data['refreshToken'] as String);

    // Fetch the profile immediately after login
    final user = await getMe();
    await prefs.setString('current_user', jsonEncode({
      'id':           user.id,
      'email':        user.email,
      'name':         user.name,
      'role':         user.role,
      'rollNumber':   user.rollNumber,
      'photoUrl':     user.photoUrl,
      'rewardPoints': user.rewardPoints,
    }));
    return user;
  }

  // ── Restore user from local storage (avoids extra API call on cold start) ─
  Future<UserModel?> getStoredUser() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString('current_user');
    if (raw == null) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  // ── Fetch profile from API ────────────────────────────────────────────────
  Future<UserModel> getMe() async {
    final data = await api.get(kMe);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  // ── Logout ────────────────────────────────────────────────────────────────
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refresh = prefs.getString('refresh_token');
    try {
      if (refresh != null) {
        await api.post(kLogout, body: {'refreshToken': refresh});
      }
    } catch (_) { /* ignore network errors on logout */ }
    await prefs.remove('access_token');
    await prefs.remove('refresh_token');
    await prefs.remove('current_user');
  }

  // ── Check if user is still logged in (token exists) ──────────────────────
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('access_token');
  }
}

final authService = AuthService.instance;
