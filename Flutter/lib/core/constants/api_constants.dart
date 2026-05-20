import 'package:flutter/foundation.dart';

class ApiConstants {
  // Use --dart-define=IS_PRODUCTION=true para apontar para a API na VPS.
  static const bool isProduction = bool.fromEnvironment(
    'IS_PRODUCTION',
    defaultValue: false,
  );

  static const String productionBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'http://18.229.149.163:3000',
  );

  static String get baseUrl {
    if (isProduction) {
      return productionBaseUrl;
    }

    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  static String get authUrl => '$baseUrl/api/auth';
  static String get tasksUrl => '$baseUrl/api/tasks';
  static String get adminUrl => '$baseUrl/api/admin';
  static String get checkinsUrl => '$baseUrl/api/checkins';
}
