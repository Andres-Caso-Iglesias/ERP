/// @file purchases_module_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene los widgets de la interfaz de usuario para la pantalla de gestión de compras.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/purchases/viewmodels/purchases_viewmodel.dart';
import 'package:erp_food_bites/modules/purchases/models/purchase.dart';

class PurchasesModuleScreen extends StatelessWidget {
  const PurchasesModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => PurchasesViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Compras'),
          backgroundColor: Colors.indigo,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<PurchasesViewModel>().fetchPurchases();
              },
            ),
          ],
        ),
        body: Consumer<PurchasesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.purchases.isEmpty) {
              return const Center(child: Text('No hay compras registradas.'));
            } else {
              return ListView.builder(
                itemCount: viewModel.purchases.length,
                itemBuilder: (context, index) {
                  final purchase = viewModel.purchases[index];
                  return _buildPurchaseCard(purchase, context);
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddPurchaseDialog(context),
          backgroundColor: Colors.indigo,
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  void _showAddPurchaseDialog(BuildContext context) {
    final supplierController = TextEditingController();
    final amountController = TextEditingController();
    String statusValue = 'Completada';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Añadir Nueva Compra'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: supplierController,
                      decoration: const InputDecoration(labelText: 'Proveedor'),
                    ),
                    TextField(
                      controller: amountController,
                      decoration: const InputDecoration(labelText: 'Monto Total'),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField(
                      value: statusValue,
                      decoration: const InputDecoration(labelText: 'Estado'),
                      items: ['Completada', 'Pendiente']
                          .map((status) => DropdownMenuItem(
                                value: status,
                                child: Text(status),
                              ))
                          .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          statusValue = newValue!;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final viewModel = context.read<PurchasesViewModel>();
                    final newPurchase = Purchase(
                      id: '', // El ID se asigna en el backend
                      supplierName: supplierController.text,
                      date: DateTime.now(),
                      totalAmount: double.tryParse(amountController.text) ?? 0.0,
                      status: statusValue,
                    );
                    final success = await viewModel.addPurchase(newPurchase);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            success ? 'Compra añadida con éxito' : 'Error al añadir la compra',
                          ),
                          backgroundColor: success ? Colors.green : Colors.red,
                        ),
                      );
                    }
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    ).then((_) {
      supplierController.dispose();
      amountController.dispose();
    });
  }

  Widget _buildPurchaseCard(Purchase purchase, BuildContext context) {
    final isCompleted = purchase.status == 'Completada';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isCompleted ? Colors.green[100] : Colors.amber[100],
          child: Icon(
            isCompleted ? Icons.check_circle_outline : Icons.pending_actions,
            color: isCompleted ? Colors.green : Colors.amber,
          ),
        ),
        title: Text(
          purchase.supplierName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Fecha: ${purchase.date.toLocal().toString().split(' ')[0]}'),
        trailing: Text(
          '€${purchase.totalAmount.toStringAsFixed(2)}',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        onTap: () {
          // TODO: Implementar un diálogo para ver/editar la compra
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalles de la compra #${purchase.id}')),
          );
        },
      ),
    );
  }
}