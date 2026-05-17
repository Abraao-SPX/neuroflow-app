import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';

class AuthService {
  static String get baseUrl => ApiConstants.authUrl;
  static const String _authTokenKey = 'auth_token';
  static String? _sessionToken;

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

      _sessionToken = token;
      await clearPersistedSession();
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
        _sessionToken = token;
        await clearPersistedSession();
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao realizar cadastro.');
    }
  }

  // Token de sessao: existe apenas enquanto o app esta aberto.
  static Future<String?> getStoredToken() async {
    return _sessionToken;
  }

  // Remove tokens persistidos por versoes antigas do app.
  static Future<void> clearPersistedSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authTokenKey);
  }

  // Limpa a sessao atual.
  static Future<void> logout() async {
    _sessionToken = null;
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
