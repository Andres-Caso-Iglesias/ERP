/// @file reports_module_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene los widgets de la interfaz de usuario para la pantalla de visualización de reportes.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/reports/viewmodels/reports_viewmodel.dart';
import 'package:erp_food_bites/modules/reports/models/report_item.dart';

class ReportsModuleScreen extends StatelessWidget {
  const ReportsModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 800 ? 4 : (screenWidth > 600 ? 3 : 2);

    return ChangeNotifierProvider(
      create: (context) => ReportsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Informes'),
          backgroundColor: Colors.purple,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: () {
                context.read<ReportsViewModel>().loadReports();
              },
            ),
          ],
        ),
        body: Consumer<ReportsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.reportItems.isEmpty) {
              return const Center(child: Text('No hay informes disponibles.'));
            } else {
              return GridView.builder(
                padding: const EdgeInsets.all(16.0),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16.0,
                  mainAxisSpacing: 16.0,
                  childAspectRatio: 1.0,
                ),
                itemCount: viewModel.reportItems.length,
                itemBuilder: (context, index) {
                  final reportItem = viewModel.reportItems[index];
                  return _buildReportCard(reportItem, context);
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildReportCard(ReportItem item, BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalles del informe: ${item.title}')),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                item.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '${item.value.toStringAsFixed(item.value.truncateToDouble() == item.value ? 0 : 2)} ${item.unit}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  color: Colors.purple,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item.description,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}