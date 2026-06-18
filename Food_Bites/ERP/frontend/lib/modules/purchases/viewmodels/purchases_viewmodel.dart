/// @file purchases_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para la gestión de compras, comunicándose con la API y actualizando la vista.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/purchase.dart';

class PurchasesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Purchase> _purchases = [];

  bool get isLoading => _isLoading;
  List<Purchase> get purchases => _purchases;

  // URL en config.dart
  final String _baseUrl = '$kBaseUrl/purchases';

  PurchasesViewModel() {
    fetchPurchases();
  }

  /// Carga la lista de compras desde la API (simulado).
  Future<void> fetchPurchases() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Reemplazar con una llamada real a la API
      await Future.delayed(const Duration(seconds: 2));
      final response = await http.get(Uri.parse(_baseUrl));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _purchases = data.map((json) => Purchase.fromJson(json)).toList();
        debugPrint('Compras cargadas con éxito.');
      } else {
        debugPrint('Error al cargar compras: ${response.statusCode}');
        _purchases = _fetchMockPurchases(); // Usar datos de respaldo
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      _purchases = _fetchMockPurchases(); // Usar datos de respaldo
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método para simular la obtención de datos, útil para el desarrollo.
  List<Purchase> _fetchMockPurchases() {
    return [
      Purchase(id: 'C001', supplierName: 'Proveedor X', date: DateTime(2024, 7, 20), totalAmount: 500.00, status: 'Completada'),
      Purchase(id: 'C002', supplierName: 'Proveedor Y', date: DateTime(2024, 7, 18), totalAmount: 1250.75, status: 'Pendiente'),
      Purchase(id: 'C003', supplierName: 'Proveedor Z', date: DateTime(2024, 7, 15), totalAmount: 300.00, status: 'Completada'),
    ];
  }

  /// Añade una nueva compra a través de la API (simulado).
  Future<bool> addPurchase(Purchase newPurchase) async {
    try {
      // Aquí se usaría el método http.post(body: json.encode(newPurchase.toJson()))
      await Future.delayed(const Duration(milliseconds: 500)); 
      final createdPurchase = Purchase(
        id: 'C00${_purchases.length + 1}',
        supplierName: newPurchase.supplierName,
        date: newPurchase.date,
        totalAmount: newPurchase.totalAmount,
        status: newPurchase.status,
      );
      _purchases.add(createdPurchase);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al añadir compra: $e');
      return false;
    }
  }

}