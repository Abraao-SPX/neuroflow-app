import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/api_constants.dart';

class AuthService {
  static String get baseUrl => ApiConstants.authUrl;
  static const String _authTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userKey = 'cached_user';
  static const Duration _requestTimeout = Duration(seconds: 20);
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

  static Future<http.Response> _postJson(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    try {
      return await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception('Tempo esgotado ao conectar com a API.');
    } on http.ClientException {
      throw Exception(
        'Nao foi possivel conectar com a API. Verifique se o servidor esta online e se o CORS permite este app.',
      );
    }
  }

  static Future<http.Response> _postAuthorizedJson(
    Uri url,
    Map<String, dynamic> body,
  ) async {
    final token = await getStoredToken();
    if (token == null) throw Exception('Nao autenticado.');

    try {
      return await http
          .post(
            url,
            headers: {
              'Content-Type': 'application/json',
              'Authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception('Tempo esgotado ao conectar com a API.');
    } on http.ClientException {
      throw Exception('Nao foi possivel conectar com a API.');
    }
  }

  static Future<http.Response> _getAuthorizedJson(Uri url) async {
    final token = await getStoredToken();
    if (token == null) throw Exception('Nao autenticado.');

    try {
      return await http
          .get(url, headers: {'Authorization': 'Bearer $token'})
          .timeout(_requestTimeout);
    } on TimeoutException {
      throw Exception('Tempo esgotado ao conectar com a API.');
    } on http.ClientException {
      throw Exception('Nao foi possivel conectar com a API.');
    }
  }

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await _postJson(url, {
      'email': email,
      'password': password,
    });

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

    final response = await _postJson(url, {
      'name': name,
      'email': email,
      'password': password,
    });

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
    if (_currentUser != null) {
      await prefs.setString(_userKey, jsonEncode(_currentUser));
    }
  }

  static Future<Map<String, dynamic>?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();

    final token = prefs.getString(_authTokenKey);
    if (token == null) {
      return null;
    }

    _sessionToken = token;

    if (_currentUser == null) {
      final userStr = prefs.getString(_userKey);
      if (userStr != null) {
        try {
          _currentUser = jsonDecode(userStr);
        } catch (_) {}
      }
    }

    // Refresh no background sem travar o startup offline
    refreshAccessToken().catchError((_) => null);

    return {'token': token, 'accessToken': token, 'user': _currentUser};
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

    final response = await _postJson(Uri.parse('$baseUrl/refresh'), {
      'refreshToken': refreshToken,
    });

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
    await prefs.remove(_userKey);
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    final refreshToken = prefs.getString(_refreshTokenKey);
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _postJson(Uri.parse('$baseUrl/logout'), {
          'refreshToken': refreshToken,
        });
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

    final response = await _postJson(url, {'email': email});

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

    final response = await _postJson(url, {
      'token': token,
      'newPassword': newPassword,
    });

    final data = _safeDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao redefinir senha.');
    }
  }

  static Future<Map<String, dynamic>> getParentAccessStatus() async {
    final response = await _getAuthorizedJson(
      Uri.parse('$baseUrl/parent-access'),
    );
    final data = _safeDecode(response.body);

    if (response.statusCode == 200) {
      final status = data['data'];
      return status is Map<String, dynamic> ? status : {};
    }

    throw Exception(data['message'] ?? 'Erro ao carregar responsavel.');
  }

  static Future<Map<String, dynamic>> requestParentAccessCode(
    String email,
  ) async {
    final response = await _postAuthorizedJson(
      Uri.parse('$baseUrl/parent-access/request-code'),
      {'email': email},
    );
    final data = _safeDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Erro ao enviar codigo.');
  }

  static Future<Map<String, dynamic>> confirmParentAccess({
    required String email,
    required String code,
    required String password,
  }) async {
    final response = await _postAuthorizedJson(
      Uri.parse('$baseUrl/parent-access/confirm'),
      {'email': email, 'code': code, 'password': password},
    );
    final data = _safeDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    }

    throw Exception(data['message'] ?? 'Erro ao confirmar responsavel.');
  }
}
