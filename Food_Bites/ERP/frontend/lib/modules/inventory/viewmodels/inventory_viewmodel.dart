/// @file inventory_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para la gestión del inventario, comunicándose con la API y actualizado la vista.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:erp_food_bites/modules/inventory/models/inventory_item.dart';

class InventoryViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Product> _products = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<Product> get products => _products;
  String? get errorMessage => _errorMessage;

  final String _baseUrl = '$kBaseUrl/inventory';
  final _secureStorage = const FlutterSecureStorage();

  InventoryViewModel() {
    fetchProducts();
  }

  //funcion IMPORTANTE obtiene cabeceras de autenticacion
  Future<Map<String, String>> _getAuthHeaders() async {
    final token = await _secureStorage.read(key: 'jwt');
    if (token == null) {
      // Manejar el caso de que no haya token (ej. redirigir al login)
      return {};
    }
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  //Obtiene todos los productos del inventario
  Future<void> fetchProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final headers = await _getAuthHeaders();
      final response = await http.get(Uri.parse(_baseUrl), headers: headers);
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _products = data.map((json) => Product.fromJson(json)).toList();
        debugPrint('Productos cargados con éxito.');
      } else if (response.statusCode == 401) {
        _errorMessage = 'Autenticación fallida. Por favor, inicia sesión de nuevo.';
        debugPrint('Error 401 al cargar productos.');
        //_products = _fetchMockProducts(); // Mostrar datos de respaldo
      } else {
        _errorMessage = 'No se pudieron cargar los productos. Código de error: ${response.statusCode}';
        //_products = _fetchMockProducts();
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      _errorMessage = 'Error de conexión. Verifica tu red.';
      //_products = _fetchMockProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Proporciona datos de ejemplo para el modo de desarrollo o en caso de fallo de la API.
  /*List<Product> _fetchMockProducts() {
    return [
      Product(id: 1, productName: 'Harina', quantity: 50, price: 1.5, category: 'Ingredientes'),
      Product(id: 2, productName: 'Tomates', quantity: 120, price: 0.8, category: 'Vegetales'),
      Product(id: 3, productName: 'Queso Mozzarella', quantity: 75, price: 5.2, category: 'Lácteos'),
    ];
  }*/

  //Añade un nuevo producto
  Future<bool> addProduct(Product newProduct) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: headers,
        body: json.encode(newProduct.toJson()),
      );

      if (response.statusCode == 201) {
        final createdProduct = Product.fromJson(json.decode(response.body));
        _products.add(createdProduct);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al crear producto: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al añadir producto: $e');
      return false;
    }
  }

  //Actualiza un producto existente
  Future<bool> updateProduct(Product updatedProduct) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.put(
        Uri.parse('$_baseUrl/${updatedProduct.id}'),
        headers: headers,
        body: json.encode(updatedProduct.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedData = Product.fromJson(json.decode(response.body));
        final index = _products.indexWhere((product) => product.id == updatedData.id);
        if (index != -1) {
          _products[index] = updatedData;
          notifyListeners();
        }
        return true;
      } else {
        debugPrint('Error al modificar producto: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al modificar producto: $e');
      return false;
    }
  }

  //Elimina un producto
  Future<bool> deleteProduct(int id) async {
    try {
      final headers = await _getAuthHeaders();
      final response = await http.delete(
        Uri.parse('$_baseUrl/$id'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        _products.removeWhere((product) => product.id == id);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al eliminar producto: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al eliminar producto: $e');
      return false;
    }
  }
}