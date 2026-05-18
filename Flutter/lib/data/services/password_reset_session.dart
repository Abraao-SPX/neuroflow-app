import 'package:shared_preferences/shared_preferences.dart';

class PasswordResetSession {
  static const String _pendingEmailKey = 'pending_reset_email';
  static const String _pendingTokenKey = 'pending_reset_token';
  static const String _pendingAtKey = 'pending_reset_requested_at';
  static const int _pendingResetWindowMs = 5 * 60 * 1000;

  static Future<PasswordResetData?> restore() async {
    final prefs = await SharedPreferences.getInstance();
    final requestedAt = prefs.getInt(_pendingAtKey);
    if (requestedAt == null) return null;

    final isStillValid =
        DateTime.now().millisecondsSinceEpoch - requestedAt <
        _pendingResetWindowMs;
    if (!isStillValid) {
      await clear();
      return null;
    }

    final email = prefs.getString(_pendingEmailKey);
    if (email == null || email.isEmpty) return null;

    return PasswordResetData(
      email: email,
      token: prefs.getString(_pendingTokenKey),
    );
  }

  static Future<bool> hasPendingReset() async {
    return await restore() != null;
  }

  static Future<void> save({required String email, String? token}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_pendingEmailKey, email.trim());
    await prefs.setInt(_pendingAtKey, DateTime.now().millisecondsSinceEpoch);

    if (token != null && token.isNotEmpty) {
      await prefs.setString(_pendingTokenKey, token);
    }
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingEmailKey);
    await prefs.remove(_pendingTokenKey);
    await prefs.remove(_pendingAtKey);
  }
}

class PasswordResetData {
  const PasswordResetData({required this.email, this.token});

  final String email;
  final String? token;
}
