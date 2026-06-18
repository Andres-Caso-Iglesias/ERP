/// @file clients_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para la gestión de clientes.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/client.dart';

class ClientsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Client> _clients = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Client> get clients => _clients;
  String? get errorMessage => _errorMessage;

  final String _baseUrl = '$kBaseUrl/clients';
  final _secureStorage = const FlutterSecureStorage();

  ClientsViewModel() {
    fetchClients();
  }

  // Método para obtener los headers de autenticación con el token JWT
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: 'jwt');
    if (token == null) {
      // Si no hay token, la solicitud fallará con 401
      return {}; 
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  // Obtiene la lista de clientes
  Future<void> fetchClients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _clients = data.map((json) => Client.fromJson(json)).toList();
      } else if (response.statusCode == 401) {
        _errorMessage = 'Autenticación fallida. Por favor, inicia sesión.';
      } else {
        debugPrint('Error al cargar clientes: ${response.statusCode}');
        _errorMessage = 'Error al cargar clientes. Código: ${response.statusCode}';
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      _errorMessage = 'Error de conexión. Verifique la red y la IP.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Añade un nuevo cliente
  Future<bool> addClient(Client newClient) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode(newClient.toJson()),
      );

      if (response.statusCode == 201) {
        final createdClient = Client.fromJson(json.decode(response.body));
        _clients.add(createdClient);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al crear cliente: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al añadir cliente: $e');
      return false;
    }
  }

  // Actualiza un cliente
  Future<bool> updateClient(Client updatedClient) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/${updatedClient.id}'),
        headers: headers,
        body: json.encode(updatedClient.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedData = Client.fromJson(json.decode(response.body));
        final index = _clients.indexWhere((client) => client.id == updatedData.id);
        if (index != -1) {
          _clients[index] = updatedData;
          notifyListeners();
        }
        return true;
      } else {
        debugPrint('Error al modificar cliente: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al modificar cliente: $e');
      return false;
    }
  }

  // Elimina un cliente
  Future<bool> deleteClient(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(Uri.parse('$_baseUrl/$id'), headers: headers);

      if (response.statusCode == 200) {
        _clients.removeWhere((client) => client.id == id);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al eliminar cliente: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al eliminar cliente: $e');
      return false;
    }
  }
}