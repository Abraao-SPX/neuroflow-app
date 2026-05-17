import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';

class AuthService {
  // A URL agora é gerenciada de forma unificada no ApiConstants (fácil deploy Pro MVP)
  static String get baseUrl => ApiConstants.authUrl;

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
      // Armazena o token localmente
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_token', data['token']);
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
      // Armazena o token localmente
      final prefs = await SharedPreferences.getInstance();
      if (data['token'] != null) {
        await prefs.setString('auth_token', data['token']);
      }
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao realizar cadastro.');
    }
  }

  // Função para recuperar token armazenado
  static Future<String?> getStoredToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Função para limpar token (logout)
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
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
        data['message'] ?? 'Erro ao solicitar recuperação de senha.',
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
