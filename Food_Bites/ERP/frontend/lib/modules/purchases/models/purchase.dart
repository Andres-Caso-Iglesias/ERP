/// @file purchase.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Define la estructura de datos para una compra en el sistema.
library;

class Purchase {
  final String id;
  final String supplierName;
  final DateTime date;
  final double totalAmount;
  final String status;

  Purchase({
    required this.id,
    required this.supplierName,
    required this.date,
    required this.totalAmount,
    required this.status,
  });

  factory Purchase.fromJson(Map<String, dynamic> json) {
    return Purchase(
      id: json['id'] as String,
      supplierName: json['supplier_name'] as String,
      date: DateTime.parse(json['date']),
      totalAmount: (json['total_amount'] as num).toDouble(),
      status: json['status'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'supplier_name': supplierName,
      'date': date.toIso8601String(),
      'total_amount': totalAmount,
      'status': status,
    };
  }
}