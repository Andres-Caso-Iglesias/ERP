// @file accounting_module_screen.dart
// @author Andres Caso Iglesias
// @date Septiembre 2025
// @brief widgets de la interfaz de usuario para el módulo de contabilidad.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:erp_food_bites/modules/accounting/viewmodels/accounting_viewmodel.dart';
import 'package:erp_food_bites/modules/accounting/models/transaction.dart';

class AccountingModuleScreen extends StatefulWidget {
  const AccountingModuleScreen({super.key});

  @override
  State<AccountingModuleScreen> createState() => _AccountingModuleScreenState();
}

class _AccountingModuleScreenState extends State<AccountingModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();
  final _amountController = TextEditingController();
  final _categoryController = TextEditingController();
  String _typeValue = 'Ingreso';
  DateTime _selectedDate = DateTime.now();

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _resetFormFields() {
    _descriptionController.clear();
    _amountController.clear();
    _categoryController.clear();
    _typeValue = 'Ingreso';
    _selectedDate = DateTime.now();
  }

  void _showTransactionDialog({Transaction? transactionToEdit}) {
    if (transactionToEdit != null) {
      _descriptionController.text = transactionToEdit.description;
      _amountController.text = transactionToEdit.amount.toString();
      _categoryController.text = transactionToEdit.category ?? '';
      _typeValue = transactionToEdit.type;
      _selectedDate = transactionToEdit.transactionDate;
    } else {
      _resetFormFields();
    }

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(transactionToEdit == null ? 'Añadir Nueva Transacción' : 'Modificar Transacción'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _descriptionController,
                        decoration: const InputDecoration(labelText: 'Descripción'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa una descripción';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _amountController,
                        decoration: const InputDecoration(labelText: 'Monto'),
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        validator: (value) {
                          if (value == null || value.isEmpty || double.tryParse(value) == null) {
                            return 'Por favor, ingresa un monto válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _typeValue,
                        decoration: const InputDecoration(labelText: 'Tipo'),
                        items: ['Ingreso', 'Gasto']
                            .map((type) => DropdownMenuItem(
                                  value: type,
                                  child: Text(type),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _typeValue = newValue!;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _categoryController,
                        decoration: const InputDecoration(labelText: 'Categoría (Opcional)'),
                      ),
                      ListTile(
                        title: Text('Fecha: ${DateFormat('dd-MM-yyyy').format(_selectedDate)}'),
                        trailing: const Icon(Icons.calendar_today),
                        onTap: () async {
                          final DateTime? picked = await showDatePicker(
                            context: context,
                            initialDate: _selectedDate,
                            firstDate: DateTime(2000),
                            lastDate: DateTime(2101),
                          );
                          if (!context.mounted) return;
                          if (picked != null && picked != _selectedDate) {
                            setState(() {
                              _selectedDate = picked;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancelar'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final viewModel = context.read<AccountingViewModel>();
                      final transaction = Transaction(
                        id: transactionToEdit?.id,
                        transactionDate: _selectedDate,
                        description: _descriptionController.text,
                        amount: double.parse(_amountController.text),
                        type: _typeValue,
                        category: _categoryController.text.isNotEmpty ? _categoryController.text : null,
                      );
                      
                      bool success;
                      if (transactionToEdit == null) {
                        success = await viewModel.addTransaction(transaction);
                        if (!context.mounted) return;
                        _showSnackBar(success ? 'Transacción añadida correctamente' : 'Error al añadir la transacción', isError: !success);
                      } else {
                        success = await viewModel.updateTransaction(transaction);
                        if (!context.mounted) return;
                        _showSnackBar(success ? 'Transacción modificada correctamente' : 'Error al modificar la transacción', isError: !success);
                      }
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(transactionToEdit == null ? 'Guardar' : 'Modificar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Módulo de Contabilidad'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<AccountingViewModel>().fetchTransactions(),
          ),
        ],
      ),
      body: Consumer<AccountingViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.transactions.isEmpty) {
            return const Center(child: Text('No hay transacciones registradas.'));
          } else {
            return ListView.builder(
              itemCount: viewModel.transactions.length,
              itemBuilder: (context, index) {
                final transaction = viewModel.transactions[index];
                return _buildTransactionCard(transaction, context);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showTransactionDialog(),
        backgroundColor: Colors.teal,
        child: const Icon(Icons.add_circle_outline),
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction, BuildContext context) {
    final isIncome = transaction.type == 'Ingreso';
    final amountColor = isIncome ? Colors.green[700] : Colors.red[700];

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isIncome ? Colors.green[100] : Colors.red[100],
          child: Icon(
            isIncome ? Icons.attach_money : Icons.money_off,
            color: isIncome ? Colors.green : Colors.red,
          ),
        ),
        title: Text(
          transaction.description,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fecha: ${DateFormat('dd-MM-yyyy').format(transaction.transactionDate)}'),
            Text('Categoría: ${transaction.category ?? 'Sin Categoría'}'),
          ],
        ),
        trailing: SizedBox(
          width: 150, // Ajusta el ancho para que los botones y el texto no se superpongan
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${isIncome ? '+' : '-'}€${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: amountColor,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showTransactionDialog(transactionToEdit: transaction),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  if (transaction.id == null) {
                    _showSnackBar('No se puede eliminar una transacción sin ID', isError: true);
                    return;
                  }
                  final bool confirmDelete = await _showDeleteConfirmationDialog(context);
                  if (confirmDelete) {
                    final viewModel = context.read<AccountingViewModel>();
                    final success = await viewModel.deleteTransaction(transaction.id!);
                    if (!context.mounted) return;
                    _showSnackBar(success ? 'Transacción eliminada correctamente' : 'Error al eliminar la transacción', isError: !success);
                  }
                },
              ),
            ],
          ),
        ),
        onTap: () {
          _showSnackBar('ID: ${transaction.id}');
        },
      ),
    );
  }
}

/// Diálogo de confirmación para eliminar una transacción
Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar esta transacción?'),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      );
    },
  ) ?? false;
}