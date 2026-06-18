/// @file sales_module_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene los widgets de la interfaz de usuario para la pantalla de gestión de ventas.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/sales/viewmodels/sales_viewmodel.dart';
import 'package:erp_food_bites/modules/sales/models/sale.dart';

class SalesModuleScreen extends StatelessWidget {
  const SalesModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => SalesViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Ventas'),
          backgroundColor: Colors.deepOrange,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                Provider.of<SalesViewModel>(context, listen: false).fetchSales();
              },
            ),
          ],
        ),
        body: Consumer<SalesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.sales.isEmpty) {
              return const Center(child: Text('No hay ventas registradas.'));
            } else {
              return ListView.builder(
                itemCount: viewModel.sales.length,
                itemBuilder: (context, index) {
                  final sale = viewModel.sales[index];
                  return _buildSaleCard(sale, context);
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            final viewModel = context.read<SalesViewModel>();
            final newSale = Sale(
              customerName: 'Cliente Test',
              amount: 100.0,
              status: 'Pagado',
              saleDate: DateTime.now(),
            );
            
            // Añadido: Mostrar un CircularProgressIndicator mientras se procesa la petición
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Row(children: [CircularProgressIndicator(), SizedBox(width: 10), Text('Añadiendo venta...')])),
            );

            final success = await viewModel.addSale(newSale);
            
            if (context.mounted) {
              // Limpiar el snackbar anterior
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Venta añadida con éxito'), backgroundColor: Colors.green),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Error al añadir la venta. Inténtalo de nuevo.'), backgroundColor: Colors.red),
                );
              }
            }
          },
          backgroundColor: Colors.deepOrange,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildSaleCard(Sale sale, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: sale.status == 'Pagado' ? Colors.green[100] : Colors.amber[100],
          child: Icon(
            sale.status == 'Pagado' ? Icons.check_circle_outline : Icons.pending_actions,
            color: sale.status == 'Pagado' ? Colors.green : Colors.amber,
          ),
        ),
        title: Text(
          sale.customerName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Fecha: ${sale.saleDate.toLocal().toString().split(' ')[0]}'),
        trailing: Text(
          '€${sale.amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: sale.status == 'Pagado' ? Colors.green[700] : Colors.red[700],
          ),
        ),
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalles de la venta #${sale.id}')),
          );
        },
      ),
    );
  }
}