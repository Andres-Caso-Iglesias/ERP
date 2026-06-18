/// @file report_item.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Define la estructura de datos para los reportes financieros y de inventario.
library;

class ReportItem {
  final String id;
  final String title;
  final double value;
  final String unit; // Ej: '€', '%', 'Unidades'
  final String description;

  ReportItem({
    required this.id,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
  });
}