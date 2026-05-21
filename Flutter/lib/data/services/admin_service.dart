import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class AdminDashboardData {
  AdminDashboardData({required this.users, required this.summary});

  final List<dynamic> users;
  final Map<String, int> summary;
}

class AdminService {
  String get _baseUrl => ApiConstants.adminUrl;

  Future<AdminDashboardData> getDashboard() async {
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
        final users = data['data'] as List<dynamic>;
        return AdminDashboardData(
          users: users,
          summary: _readSummary(data['summary'], users),
        );
      }
      if (data is List) {
        return AdminDashboardData(users: data, summary: _readSummary(null, data));
      }
      throw Exception('Resposta invalida ao carregar usuarios.');
    } else {
      throw Exception(_extractErrorMessage(response, 'Falha ao carregar usuarios'));
    }
  }

  Future<List<dynamic>> getUsers() async {
    final dashboard = await getDashboard();
    return dashboard.users;
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

  Future<void> setUserBanned(int id, bool banned) async {
    final token = await AuthService.getStoredToken();
    if (token == null) {
      throw Exception('Sessao expirada. Faca login novamente.');
    }

    var response = await _setUserBannedWithToken(id, banned, token);
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await AuthService.refreshAccessToken();
      final refreshedToken = refreshed?['token'];
      if (refreshedToken is String) {
        response = await _setUserBannedWithToken(id, banned, refreshedToken);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      _extractErrorMessage(
        response,
        banned ? 'Falha ao banir usuario' : 'Falha ao reativar usuario',
      ),
    );
  }

  Future<void> promoteUserToAdmin(int id) async {
    final token = await AuthService.getStoredToken();
    if (token == null) {
      throw Exception('Sessao expirada. Faca login novamente.');
    }

    var response = await _promoteUserToAdminWithToken(id, token);
    if (response.statusCode == 401 || response.statusCode == 403) {
      final refreshed = await AuthService.refreshAccessToken();
      final refreshedToken = refreshed?['token'];
      if (refreshedToken is String) {
        response = await _promoteUserToAdminWithToken(id, refreshedToken);
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return;
    }

    throw Exception(
      _extractErrorMessage(response, 'Falha ao tornar usuario admin'),
    );
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

  Future<http.Response> _setUserBannedWithToken(
    int id,
    bool banned,
    String token,
  ) {
    return http.patch(
      Uri.parse('$_baseUrl/users/$id/ban'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'banned': banned}),
    );
  }

  Future<http.Response> _promoteUserToAdminWithToken(int id, String token) {
    return http.patch(
      Uri.parse('$_baseUrl/users/$id/admin'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
  }

  Map<String, int> _readSummary(dynamic rawSummary, List<dynamic> users) {
    if (rawSummary is Map<String, dynamic>) {
      return {
        'total': _readInt(rawSummary['total']),
        'active': _readInt(rawSummary['active']),
        'banned': _readInt(rawSummary['banned']),
        'admins': _readInt(rawSummary['admins']),
      };
    }

    var active = 0;
    var banned = 0;
    var admins = 0;
    for (final user in users) {
      if (user is! Map) continue;
      if (user['role'] == 'admin') admins += 1;
      if (user['status'] == 'banned') {
        banned += 1;
      } else {
        active += 1;
      }
    }

    return {
      'total': users.length,
      'active': active,
      'banned': banned,
      'admins': admins,
    };
  }

  int _readInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
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
