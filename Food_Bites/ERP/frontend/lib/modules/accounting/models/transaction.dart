// @file transaction.dart
// @author Andres Caso Iglesias
// @date Septiembre 2025
// @brief Define la estructura de datos para una transacción financiera.
library;

//dejare en final hasta implementar la opcion de modificar
class Transaction {
  final int? id;
  final DateTime transactionDate;
  final String description;
  final double amount;
  final String type; // 'Ingreso' o 'Gasto'
  final String? category;

  Transaction({
    this.id,
    required this.transactionDate,
    required this.description,
    required this.amount,
    required this.type,
    this.category,
  });

  //deserializar
  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      transactionDate: DateTime.parse(json['transaction_date'] as String),
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      category: json['category'] as String?,
    );
  }

  //serializar
  Map<String, dynamic> toJson() {
    return {
      'transaction_date': transactionDate.toIso8601String(),
      'description': description,
      'amount': amount,
      'type': type,
      'category': category,
    };
  }
}