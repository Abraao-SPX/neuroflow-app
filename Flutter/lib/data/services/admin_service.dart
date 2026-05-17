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

    final response = await http.get(
      Uri.parse('$_baseUrl/users'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

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

    final response = await http.delete(
      Uri.parse('$_baseUrl/users/$id'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      final data = jsonDecode(response.body);
      throw Exception(
        data['message'] ?? data['error'] ?? 'Failed to delete user',
      );
    }
  }
}
