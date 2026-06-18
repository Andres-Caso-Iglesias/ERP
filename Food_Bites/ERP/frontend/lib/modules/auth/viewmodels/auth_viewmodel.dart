/// @file auth_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Gestiona la lógica de autenticación del usuario, login, logout y token.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthViewModel extends ChangeNotifier {
  //almacenar el token JWT y el nombre de usuario
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock),
  );
  String? _token;
  String? _username;
  bool _isLoading = false;

  bool get isAuthenticated => _token != null;
  String? get username => _username;
  bool get isLoading => _isLoading;

  // URL en config.dart
  final String _baseUrl = '$kBaseUrl/auth';

  AuthViewModel() {
    _checkAuthenticationStatus();
  }

  //Verifica autenticación
  Future<void> _checkAuthenticationStatus() async {
    _token = await _storage.read(key: 'jwt');
    if (_token != null) {
      _username = await _storage.read(key: 'username');
    }
    notifyListeners();
  }

  //niciar sesión con el nombre de usuario y la contraseña
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    notifyListeners();
    debugPrint('INICIANDO SESIÓN para: $username');

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'username': username, 'password': password}),
      );

      debugPrint('Código de estado: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _token = data['token'];
        _username = data['user']['username'];
        await _storage.write(key: 'jwt', value: _token);
        await _storage.write(key: 'username', value: _username);
        notifyListeners();
        _isLoading = false;
        return true;
      } else {
        // En caso de credenciales incorrectas o error del servidor
        _isLoading = false;
        notifyListeners();
        debugPrint('Error de autenticación: ${response.body}');
        return false;
      }
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      debugPrint('Error de conexión al intentar iniciar sesión: $e');
      return false;
    }
  }

  //Cierra la sesión y elimina el token JWT y el nombre
  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
    await _storage.delete(key: 'username');
    _token = null;
    _username = null;
    notifyListeners();
  }
}