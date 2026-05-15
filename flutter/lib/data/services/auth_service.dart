import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  // URL da API (use 10.0.2.2:3000 internamente no emulador Android)
  static const String baseUrl = 'http://localhost:3000/api/auth';

  static Future<Map<String, dynamic>> login(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao realizar login.');
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password) async {
    final url = Uri.parse('$baseUrl/register');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'name': name,
        'email': email,
        'password': password,
      }),
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 201) {
      return data;
    } else {
      throw Exception(data['message'] ?? 'Erro ao realizar cadastro.');
    }
  }
}
