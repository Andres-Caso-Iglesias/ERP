/// @file human_resources_module_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene los widgets de la interfaz de usuario para la pantalla de gestión de recursos humanos.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/human_resources/viewmodels/human_resources_viewmodel.dart';
import 'package:erp_food_bites/modules/human_resources/models/employee.dart';

class HumanResourcesModuleScreen extends StatelessWidget {
  const HumanResourcesModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HumanResourcesViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Recursos Humanos'),
          backgroundColor: Colors.orange,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<HumanResourcesViewModel>().fetchEmployees();
              },
            ),
          ],
        ),
        body: Consumer<HumanResourcesViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.employees.isEmpty) {
              return const Center(child: Text('No hay empleados registrados.'));
            } else {
              return ListView.builder(
                itemCount: viewModel.employees.length,
                itemBuilder: (context, index) {
                  final employee = viewModel.employees[index];
                  return _buildEmployeeCard(employee, context);
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddEmployeeDialog(context),
          backgroundColor: Colors.orange,
          child: const Icon(Icons.group_add),
        ),
      ),
    );
  }

  void _showAddEmployeeDialog(BuildContext context) {
    final nameController = TextEditingController();
    final positionController = TextEditingController();
    bool isActive = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Añadir Nuevo Empleado'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Nombre'),
                    ),
                    TextField(
                      controller: positionController,
                      decoration: const InputDecoration(labelText: 'Puesto'),
                    ),
                    Row(
                      children: [
                        const Text('Activo'),
                        Switch(
                          value: isActive,
                          onChanged: (bool value) {
                            setState(() {
                              isActive = value;
                            });
                          },
                        ),
                      ],
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
                    final viewModel = context.read<HumanResourcesViewModel>();
                    final newEmployee = Employee(
                      id: '', // El ID se asigna en el backend
                      name: nameController.text,
                      position: positionController.text,
                      hireDate: DateTime.now(),
                      isActive: isActive,
                    );
                    final success = await viewModel.addEmployee(newEmployee);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(success ? 'Empleado añadido' : 'Error al añadir empleado'),
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
      nameController.dispose();
      positionController.dispose();
    });
  }

  Widget _buildEmployeeCard(Employee employee, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: employee.isActive ? Colors.green[100] : Colors.grey[300],
          child: Icon(
            employee.isActive ? Icons.person : Icons.person_off,
            color: employee.isActive ? Colors.green : Colors.grey,
          ),
        ),
        title: Text(
          employee.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Puesto: ${employee.position}\nInicio: ${employee.hireDate.toLocal().toString().split(' ')[0]}',
        ),
        trailing: Icon(
          employee.isActive ? Icons.check_circle : Icons.error,
          color: employee.isActive ? Colors.green : Colors.red,
        ),
        onTap: () {
          // Implementar la navegación a la vista de detalles
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalles del empleado #${employee.id}')),
          );
        },
      ),
    );
  }
}