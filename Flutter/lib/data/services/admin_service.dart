import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class AdminService {
  String get _baseUrl => ApiConstants.adminUrl;

  Future<List<dynamic>> getUsers() async {
    final token = await AuthService.getStoredToken();
    if (token == null) {
      throw Exception('Sessao expirada. Faca login novamente.');
    }

    var response = await _getUsersWithToken(token);
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await AuthService.refreshAccessToken();
      final refreshedToken = refreshed?['token'];
      if (refreshedToken is String) {
        response = await _getUsersWithToken(refreshedToken);
      }
    }

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data is Map<String, dynamic> && data['data'] is List) {
        return data['data'] as List<dynamic>;
      }
      if (data is List) {
        return data;
      }
      throw Exception('Resposta invalida ao carregar usuarios.');
    } else {
      throw Exception('Failed to load users: ${response.statusCode}');
    }
  }

  Future<void> deleteUser(int id) async {
    final token = await AuthService.getStoredToken();
    if (token == null) {
      throw Exception('Sessao expirada. Faca login novamente.');
    }

    var response = await _deleteUserWithToken(id, token);
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await AuthService.refreshAccessToken();
      final refreshedToken = refreshed?['token'];
      if (refreshedToken is String) {
        response = await _deleteUserWithToken(id, refreshedToken);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(_extractErrorMessage(response, 'Falha ao apagar usuario'));
  }

  Future<http.Response> _getUsersWithToken(String token) {
    return http.get(
      Uri.parse('$_baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Future<http.Response> _deleteUserWithToken(int id, String token) {
    return http.delete(
      Uri.parse('$_baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  String _extractErrorMessage(http.Response response, String fallback) {
    final body = response.body.trim();
    if (body.isEmpty) {
      return '$fallback (${response.statusCode})';
    }

    try {
      final data = jsonDecode(body);
      if (data is Map<String, dynamic>) {
        final message = data['message'] ?? data['error'];
        if (message is String && message.trim().isNotEmpty) {
          return message;
        }
      }
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
    } on FormatException {
      if (body.length <= 160) {
        return body;
      }
    }

    return '$fallback (${response.statusCode})';
  }
}
