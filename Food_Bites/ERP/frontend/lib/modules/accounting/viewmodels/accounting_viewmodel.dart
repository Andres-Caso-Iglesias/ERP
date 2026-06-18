// @file accounting_viewmodel.dart
// @author Andres Caso Iglesias
// @date Septiembre 2025
// @brief Contiene la lógica de negocio para la gestión de contabilidad.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction.dart';

class AccountingViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Transaction> _transactions = [];

  bool get isLoading => _isLoading;
  List<Transaction> get transactions => _transactions;

  // URL en config.dart
  final String _baseUrl = '$kBaseUrl/accounting';

  AccountingViewModel() {
    fetchTransactions();
  }

  /// Carga todas las transacciones desde la API.
  Future<void> fetchTransactions() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _transactions = data.map((json) => Transaction.fromJson(json)).toList();
        debugPrint('Transacciones cargadas con éxito.');
      } else {
        debugPrint('Error al cargar transacciones: ${response.statusCode}');
        //_transactions = _fetchMockTransactions();
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      //_transactions = _fetchMockTransactions();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Datos de ejemplo que se cargan si no accede a DB.
 /* List<Transaction> _fetchMockTransactions() {
    return [
      Transaction(id: 1, transactionDate: DateTime(2025, 9, 10), description: 'Venta de Productos', amount: 500.00, type: 'Ingreso', category: 'Ventas'),
      Transaction(id: 2, transactionDate: DateTime(2025, 9, 9), description: 'Pago de Alquiler', amount: 800.00, type: 'Gasto', category: 'Alquiler'),
      Transaction(id: 3, transactionDate: DateTime(2025, 9, 8), description: 'Pago de Salarios', amount: 1500.00, type: 'Gasto', category: 'Nómina'),
    ];
  }*/

  // Añade una nueva transacción.
  Future<bool> addTransaction(Transaction newTransaction) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(newTransaction.toJson()),
      );

      if (response.statusCode == 201) {
        final createdTransaction = Transaction.fromJson(json.decode(response.body));
        _transactions.add(createdTransaction);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al crear transacción: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al añadir transacción: $e');
      return false;
    }
  }

  // Actualiza una transacción existente.
  Future<bool> updateTransaction(Transaction updatedTransaction) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/${updatedTransaction.id}'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(updatedTransaction.toJson()),
      );

      if (response.statusCode == 200) {
        final updatedData = Transaction.fromJson(json.decode(response.body));
        final index = _transactions.indexWhere((transaction) => transaction.id == updatedData.id);
        if (index != -1) {
          _transactions[index] = updatedData;
          notifyListeners();
        }
        return true;
      } else {
        debugPrint('Error al modificar transacción: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al modificar transacción: $e');
      return false;
    }
  }

  // Elimina una transacción.
  Future<bool> deleteTransaction(int id) async {
    try {
      final response = await http.delete(Uri.parse('$_baseUrl/$id'));

      if (response.statusCode == 200) {
        _transactions.removeWhere((transaction) => transaction.id == id);
        notifyListeners();
        return true;
      } else {
        debugPrint('Error al eliminar transacción: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al eliminar transacción: $e');
      return false;
    }
  }
}