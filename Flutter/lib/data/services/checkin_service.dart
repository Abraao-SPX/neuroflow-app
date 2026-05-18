import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import 'auth_service.dart';

class CheckinService {
  static String get baseUrl => ApiConstants.checkinsUrl;

  static Future<void> salvarCheckin(String humor, List<String> gatilhos) async {
    final token = await AuthService.getStoredToken();
    if (token == null) throw Exception('Não autenticado');

    final url = Uri.parse(baseUrl);
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'humor': humor, 'gatilhos': gatilhos}),
    );

    if (response.statusCode != 201) {
      throw Exception('Falha ao salvar check-in: ${response.statusCode}');
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
      final decoded = jsonDecode(response.body);
      return decoded['data'] ?? [];
    } else {
      throw Exception('Falha ao listar check-ins');
    }
  }
}
