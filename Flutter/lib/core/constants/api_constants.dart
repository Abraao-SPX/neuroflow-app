import 'package:flutter/foundation.dart';

class ApiConstants {
  // CONFIGURACAO DE AMBIENTE
  // Altere para true quando for testar com a API na nuvem / servidor VPS.
  static const bool isProduction = true;

  static const String productionBaseUrl = 'http://18.229.149.163:3000';

  static String get baseUrl {
    if (isProduction) {
      return productionBaseUrl;
    }

    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  static String get authUrl => '$baseUrl/api/auth';
  static String get tasksUrl => '$baseUrl/api/tasks';
  static String get adminUrl => '$baseUrl/api/admin';
}
