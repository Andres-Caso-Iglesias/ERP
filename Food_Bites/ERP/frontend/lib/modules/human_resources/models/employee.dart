/// @file employee.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Define la estructura de datos para un empleado en el sistema.
library;

class Employee {
  final String id;
  final String name;
  final String position;
  final DateTime hireDate;
  final bool isActive;

  Employee({
    required this.id,
    required this.name,
    required this.position,
    required this.hireDate,
    required this.isActive,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      position: json['position'],
      hireDate: DateTime.parse(json['hire_date']),
      isActive: json['is_active'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'position': position,
      'hire_date': hireDate.toIso8601String(),
      'is_active': isActive,
    };
  }
}