import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/foundation.dart';

class AuthService {
  // URL da API - Detecta automaticamente se é web/desktop (localhost) ou emulador Android (10.0.2.2)
  static const String baseUrl = kIsWeb ? 'http://localhost:3000/api/auth' : 'http://10.0.2.2:3000/api/auth';

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
}
