/// @file sales_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para la gestión de ventas, comunicándose con la API.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:erp_food_bites/modules/sales/models/sale.dart';

class SalesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Sale> _sales = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Sale> get sales => _sales;
  String? get errorMessage => _errorMessage;

  // URL en config.dart
  final String _baseUrl = '$kBaseUrl/sales';
  final _secureStorage = const FlutterSecureStorage();

  SalesViewModel() {
    fetchSales();
  }

  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: 'jwt');
    if (token == null) {
      // Maneja el caso en que no haya token.
      return {};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<void> fetchSales() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _sales = data.map((json) => Sale.fromJson(json)).toList();
        debugPrint('Registros de ventas cargados con éxito.');
      } else if (response.statusCode == 401) {
        _errorMessage = 'Autenticación fallida. Por favor, inicia sesión de nuevo.';
        debugPrint('Error 401 al cargar ventas.');
        _sales = _fetchMockSales(); // Muestra datos de respaldo.
      } else {
        _errorMessage = 'No se pudieron cargar las ventas. Código de error: ${response.statusCode}';
        _sales = _fetchMockSales();
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      _errorMessage = 'Error de conexión. Verifica tu red.';
      _sales = _fetchMockSales();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  ///datos de ejemplo para el modo de desarrollo o en caso de fallo de la API.
  List<Sale> _fetchMockSales() {
    return [
      Sale(
        id: 1,
        customerName: 'Cliente A',
        saleDate: DateTime.parse('2025-09-15T10:00:00Z'),
        amount: 25.50,
        status: 'Completado',
      ),
      Sale(
        id: 2,
        customerName: 'Cliente B',
        saleDate: DateTime.parse('2025-09-14T15:30:00Z'),
        amount: 18.75,
        status: 'En Proceso',
      ),
    ];
  }

  Future<bool> addSale(Sale newSale) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode(newSale.toJson()),
      );
      if (response.statusCode == 201) {
        final createdSale = Sale.fromJson(json.decode(response.body));
        _sales.add(createdSale);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al agregar registro de ventas: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al agregar venta: $e');
      return false;
    }
  }

  Future<bool> updateSale(Sale updatedSale) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/${updatedSale.id}'),
        headers: headers,
        body: json.encode(updatedSale.toJson()),
      );
      if (response.statusCode == 200) {
        final updatedData = Sale.fromJson(json.decode(response.body));
        final index = _sales.indexWhere((sale) => sale.id == updatedData.id);
        if (index != -1) {
          _sales[index] = updatedData;
          notifyListeners();
        }
        return true;
      } else {
        debugPrint('Error al modificar registro de ventas: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al modificar venta: $e');
      return false;
    }
  }

  Future<bool> deleteSale(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
      );
      if (response.statusCode == 200) {
        _sales.removeWhere((sale) => sale.id == id);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al eliminar registro de ventas: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al eliminar venta: $e');
      return false;
    }
  }
}