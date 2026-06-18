// @file pos_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para el punto de venta, gestionando el carrito de compra y procesando las transacciones.
library;

import 'package:flutter/foundation.dart';
import '../models/product.dart';

class POSViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Product> _availableProducts = [];
  Map<Product, int> _cart = {};

  bool get isLoading => _isLoading;
  List<Product> get availableProducts => _availableProducts;
  Map<Product, int> get cart => _cart;

  double get totalAmount {
    double total = 0.0;
    _cart.forEach((product, quantity) {
      total += product.price * quantity;
    });
    return total;
  }

  POSViewModel() {
    loadProducts();
  }

  /// Simula la carga de productos del inventario
  Future<void> loadProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simula un delay para la carga de datos
      await Future.delayed(const Duration(seconds: 2));

      // Aquí iría la llamada a la API
      _availableProducts = _fetchMockProducts();
      debugPrint('Productos cargados con éxito.');
    } catch (e) {
      debugPrint('Error al cargar productos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Datos de ejemplo, método separado para mejor organización.
  /// mas adelante tirara de la DB
  List<Product> _fetchMockProducts() {
    return [
      Product(id: 'P001', name: 'Laptop Pro', price: 1200.00, stock: 15),
      Product(id: 'P002', name: 'Teclado Mecánico', price: 85.50, stock: 5),
      Product(id: 'P003', name: 'Monitor Curvo 27"', price: 350.00, stock: 2),
      Product(id: 'P004', name: 'Ratón Inalámbrico', price: 35.99, stock: 50),
      Product(id: 'P005', name: 'Auriculares Gaming', price: 75.00, stock: 0),
    ];
  }

  /// Añade un producto al carrito y actualiza el stock.
  void addProductToCart(Product product) {
    if (product.stock > 0) {
      // Busca la instancia del producto en la lista de productos disponibles
      // para que se muestren las actualizaciones 
      final productInList = _availableProducts.firstWhere(
        (p) => p.id == product.id,
        orElse: () => product,
      );

      if (_cart.containsKey(product)) {
        _cart[product] = _cart[product]! + 1;
      } else {
        _cart[product] = 1;
      }
      productInList.stock--;
      notifyListeners();
    } else {
      debugPrint('Producto sin stock: ${product.name}');
    }
  }

  /// Elimina un producto del carrito y actualiza el stock.
  void removeProductFromCart(Product product) {
    if (_cart.containsKey(product)) {
      final productInList = _availableProducts.firstWhere(
        (p) => p.id == product.id,
        orElse: () => product,
      );
      productInList.stock++;
      if (_cart[product]! > 1) {
        _cart[product] = _cart[product]! - 1;
      } else {
        _cart.remove(product);
      }
      notifyListeners();
    }
  }

  /// Simula el procesamiento de la venta.
  Future<bool> processSale() async {
    if (_cart.isNotEmpty) {
      try {
        // Simular la llamada a la API para procesar la venta
        await Future.delayed(const Duration(milliseconds: 500));
        debugPrint('Venta procesada por un total de: €${totalAmount.toStringAsFixed(2)}');
        
        // Aquí iría el código para limpiar el carrito y actualizar el estado
        _cart.clear();
        notifyListeners();
        
        // No es necesario recargar todos los productos si solo el stock cambia
        // Se podría hacer una actualización más selectiva si el backend lo permite
        return true;
      } catch (e) {
        debugPrint('Error al procesar la venta: $e');
        return false;
      }
    }
    return false;
  }
}