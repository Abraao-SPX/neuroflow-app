import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class CheckinService {
  static String get baseUrl => ApiConstants.checkinsUrl;

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

  static Future<void> salvarCheckin(String humor, List<String> gatilhos) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw Exception('Não autenticado');

    final gatilhosUnicos = gatilhos.toSet().toList();
    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'humor': humor, 'gatilhos': gatilhosUnicos}),
    );

    if (response.statusCode != 201) {
      final data = _safeDecode(response.body);
      throw Exception(
        data['message'] ?? 'Falha ao salvar check-in: ${response.statusCode}',
      );
    }
  }

  static Future<List<dynamic>> listarCheckins() async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw Exception('Não autenticado');

    final url = Uri.parse(baseUrl);
    final response = await http.get(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final decoded = _safeDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      final data = _safeDecode(response.body);
      throw Exception(data['message'] ?? 'Falha ao listar check-ins');
    }
  }

  static Future<void> apagarCheckin(int id) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw Exception('NÃ£o autenticado');

    final url = Uri.parse('$baseUrl/$id');
    final response = await http.delete(
      url,
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 204 && response.statusCode != 200) {
      final data = _safeDecode(response.body);
      throw Exception(data['message'] ?? 'Falha ao apagar check-in');
    }
  }
}
