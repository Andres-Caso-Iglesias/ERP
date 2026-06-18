/// @file inventory_item.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Define la estructura de datos para un producto en el inventario.
library;

class Product {
  final int? id;
  final String productName;
  final int quantity;
  final double price;
  final String category;

  Product({
    this.id,
    required this.productName,
    required this.quantity,
    required this.price,
    required this.category,
  });

factory Product.fromJson(Map<String, dynamic> json) {
  return Product(
    id: json['id'] as int?,
    productName: json['product_name'] as String,
    quantity: json['quantity'] as int,
    price: double.parse(json['price'].toString()),
    category: json['category'] as String,
  );
}

  Map<String, dynamic> toJson() {
    return {
      'product_name': productName,
      'quantity': quantity,
      'price': price,
      'category': category,
    };
  }
}