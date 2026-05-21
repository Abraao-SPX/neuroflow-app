import 'package:flutter/material.dart';
import '../data/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  String? _token;
  Map<String, dynamic>? _user;
  bool _isLoading = false;
  bool _isInitialized = false;

  // Getters
  String? get token => _token;
  Map<String, dynamic>? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  bool get isLoggedIn => _token != null;
  bool get isParent => _user?['role'] == 'parent';
  Map<String, dynamic>? get child {
    final childData = _user?['child'];
    return childData is Map<String, dynamic> ? childData : null;
  }

  // Inicializa tentando restaurar a sessao por refresh token.
  Future<void> initAuth() async {
    try {
      final restored = await AuthService.restoreSession();
      _token = restored?['token'];
      _user = restored?['user'];
    } catch (_) {
      _token = null;
      _user = null;
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Login
  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.login(email, password);
      _token = result['token'];
      _user = result['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Registro
  Future<bool> register(String name, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await AuthService.register(name, email, password);
      _token = result['token'];
      _user = result['user'];
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    _token = null;
    _user = null;
    notifyListeners();
    await AuthService.logout();
  }
}
