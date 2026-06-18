/// @file reports_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para la generación y gestión de informes y estadísticas del sistema.
library;

import 'package:flutter/foundation.dart';
import '../models/report_item.dart';

class ReportsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<ReportItem> _reportItems = [];

  bool get isLoading => _isLoading;
  List<ReportItem> get reportItems => _reportItems;

  ReportsViewModel() {
    loadReports();
  }

  /// Simula la carga de datos de la base de datos o una API.
  Future<void> loadReports() async {
    _isLoading = true;
    notifyListeners();

    // Simula un retardo para la carga de datos
    await Future.delayed(const Duration(seconds: 2));

    try {
      // Reemplaza esto con una llamada real a la API en el futuro
      _reportItems = await _fetchMockReports();
      debugPrint('Informes cargados con éxito.');
    } catch (e) {
      debugPrint('Error al cargar informes: $e');
      // Opcional: mostrar un mensaje de error al usuario
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Método auxiliar para simular la obtención de datos de la API.
  Future<List<ReportItem>> _fetchMockReports() async {
    return [
      ReportItem(id: 'R001', title: 'Total de Ventas', value: 5450.75, unit: '€', description: 'Ventas brutas del último mes.'),
      ReportItem(id: 'R002', title: 'Gastos Operativos', value: 1200.50, unit: '€', description: 'Gastos fijos y variables del mes.'),
      ReportItem(id: 'R003', title: 'Inventario Total', value: 250, unit: 'Unidades', description: 'Número total de productos en stock.'),
      ReportItem(id: 'R004', title: 'Margen de Beneficio', value: 25.5, unit: '%', description: 'Margen de beneficio del trimestre.'),
    ];
  }
}