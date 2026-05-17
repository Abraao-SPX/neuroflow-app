import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';

class AuthService {
  static String get baseUrl => ApiConstants.authUrl;
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static String? _sessionToken;
  static Map<String, dynamic>? _currentUser;

  static Map<String, dynamic> _safeDecode(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
    } catch (_) {
      return {};
    }

    return {};
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    final data = _safeDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];
      if (token is! String || token.isEmpty) {
        throw Exception('Resposta de login invalida.');
      }

      await _storeSession(data);
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao realizar login.');
    }
  }

  static Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    final data = _safeDecode(response.body);

    if (response.statusCode == 201) {
      final token = data['token'];
      if (token is String && token.isNotEmpty) {
        await _storeSession(data);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao realizar cadastro.');
    }
  }

  static Future<void> _storeSession(Map<String, dynamic> data) async {
    final token = data['accessToken'] ?? data['token'];
    final refreshToken = data['refreshToken'];
    if (token is! String || token.isEmpty) {
      throw Exception('Resposta sem token de acesso.');
    }
    if (refreshToken is! String || refreshToken.isEmpty) {
      throw Exception('Resposta sem refresh token.');
    }

    _sessionToken = token;
    if (data['user'] is Map<String, dynamic>) {
      _currentUser = data['user'] as Map<String, dynamic>;
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authTokenKey, token);
    await prefs.setString(_refreshTokenKey, refreshToken);
  }

  static Future<Map<String, dynamic>?> restoreSession() async {
    final token = await getStoredToken();
    if (token == null) {
      return null;
    }

    if (_currentUser != null) {
      return {'token': token, 'accessToken': token, 'user': _currentUser};
    }

    return refreshAccessToken();
  }

  static Future<String?> getStoredToken() async {
    if (_sessionToken != null) {
      return _sessionToken;
    }

    final prefs = await SharedPreferences.getInstance();
    _sessionToken = prefs.getString(_authTokenKey);
    if (_sessionToken != null) {
      return _sessionToken;
    }

    final refreshed = await refreshAccessToken();
    return refreshed?['token'] as String?;
  }

  static Future<Map<String, dynamic>?> refreshAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    final response = await http.post(
      Uri.parse('$baseUrl/refresh'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'refreshToken': refreshToken}),
    );

    final data = _safeDecode(response.body);
    if (response.statusCode == 200) {
      await _storeSession(data);
      return data;
    }

    await clearPersistedSession();
    return null;
  }

  static Future<void> clearPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
    await prefs.remove(_refreshTokenKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await http.post(
          Uri.parse('$baseUrl/logout'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({'refreshToken': refreshToken}),
        );
      } catch (_) {
        // Logout local ainda deve funcionar mesmo sem conexao.
      }
    }

    _sessionToken = null;
    _currentUser = null;
    await clearPersistedSession();
  }

  static Future<Map<String, dynamic>> forgotPassword(String email) async {
    final url = Uri.parse('$baseUrl/forgot-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email}),
    );

    final data = _safeDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(
        data['message'] ?? 'Erro ao solicitar recuperacao de senha.',
      );
    }
  }

  static Future<Map<String, dynamic>> resetPassword(
    String token,
    String newPassword,
  ) async {
    final url = Uri.parse('$baseUrl/reset-password');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'token': token, 'newPassword': newPassword}),
    );

    final data = _safeDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao redefinir senha.');
    }
  }
}
