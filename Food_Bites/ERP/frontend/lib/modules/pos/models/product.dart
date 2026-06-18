/// @file product.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Define la estructura de datos para una sesión de punto de venta.
library;

class Product {
  final String id;
  final String name;
  final double price;
  int stock; // El stock puede cambiar, por eso no es 'final'

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.stock,
  });
}