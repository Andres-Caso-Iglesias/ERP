/// @file human_resources_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para la gestión de empleados, comunicándose con la API y actualizando la vista.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/employee.dart';

class HumanResourcesViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<Employee> _employees = [];

  bool get isLoading => _isLoading;
  List<Employee> get employees => _employees;

  // URL en config.dart
  final String _baseUrl = '$kBaseUrl/employees';

  HumanResourcesViewModel() {
    fetchEmployees();
  }

  /// Carga la lista de empleados desde la API.
  Future<void> fetchEmployees() async {
    _isLoading = true;
    notifyListeners();

    try {
      // Reemplazar con una llamada real a la API
      await Future.delayed(const Duration(seconds: 2));
      final response = await http.get(Uri.parse(_baseUrl));
      
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _employees = data.map((json) => Employee.fromJson(json)).toList();
      } else {
        debugPrint('Error al cargar empleados: ${response.statusCode}');
        _employees = _fetchMockEmployees(); // Usar datos de respaldo
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      _employees = _fetchMockEmployees(); // Usar datos de respaldo
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Método para simular obtención de datos.
  List<Employee> _fetchMockEmployees() {
    return [
      Employee(id: 'E001', name: 'Laura Gómez', position: 'Gerente de Proyectos', hireDate: DateTime(2022, 1, 15), isActive: true),
      Employee(id: 'E002', name: 'Pedro Sánchez', position: 'Desarrollador Senior', hireDate: DateTime(2021, 5, 20), isActive: true),
      Employee(id: 'E003', name: 'Ana Fernández', position: 'Asistente Administrativa', hireDate: DateTime(2023, 9, 1), isActive: true),
      Employee(id: 'E004', name: 'Luis Torres', position: 'Técnico de Soporte', hireDate: DateTime(2024, 2, 10), isActive: false),
    ];
  }

  /// Añade un nuevo empleado a través de la API. de momento simuladoo
  Future<bool> addEmployee(Employee newEmployee) async {
    try {
      // Aquí se usaría el método http.post(body: json.encode(newEmployee.toJson()))
      await Future.delayed(const Duration(milliseconds: 500)); 
      final createdEmployee = Employee(
        id: 'E00${_employees.length + 1}',
        name: newEmployee.name,
        position: newEmployee.position,
        hireDate: newEmployee.hireDate,
        isActive: newEmployee.isActive,
      );
      _employees.add(createdEmployee);
      notifyListeners();
      return true;
    } catch (e) {
      debugPrint('Error al añadir empleado: $e');
      return false;
    }
  }
}