import 'package:flutter/foundation.dart';

class ApiConstants {
  // === CONFIGURAÇÃO DE AMBIENTE ===
  // 1. Altere para [true] quando for testar com a API na Nuvem / Servidor VPS
  // 2. Mantenha [false] para desenvolvimento local na própria máquina
  static const bool isProduction = false;

  // URL do seu servidor na nuvem (Ex: 'http://123.45.67.89:3000' ou 'https://api.meusite.com')
  static const String productionBaseUrl = 'http://SEU_IP_DO_SERVIDOR:3000';

  // =============== LÓGICA DE URL ===============
  static String get baseUrl {
    if (isProduction) {
      return productionBaseUrl;
    }
    // Lógica para emuladores locais vs web local
    return kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000';
  }

  // Endpoints da API
  static String get authUrl => '$baseUrl/api/auth';
  static String get tasksUrl => '$baseUrl/api/tasks';
}
