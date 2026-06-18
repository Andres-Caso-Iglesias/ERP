/// @file sale.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Define la estructura de datos para una venta en el sistema.
library;

class Sale {
  final int? id;
  final String customerName;
  final DateTime saleDate;
  final double amount;
  final String? status;

  Sale({
    this.id,
    required this.customerName,
    required this.saleDate,
    required this.amount,
    this.status,
  });

  factory Sale.fromJson(Map<String, dynamic> json) {
    return Sale(
      id: json['id'],
      customerName: json['customer_name'],
      saleDate: DateTime.parse(json['sale_date']),
      amount: double.parse(json['amount'].toString()),
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'customer_name': customerName,
      'amount': amount,
      'status': status,
    };
  }
}