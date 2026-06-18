import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/clients/viewmodels/clients_viewmodel.dart';
import 'package:erp_food_bites/modules/clients/models/client.dart';

class ClientsModuleScreen extends StatelessWidget {
  const ClientsModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => ClientsViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Módulo de Clientes'),
          backgroundColor: Colors.cyan,
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: () {
                context.read<ClientsViewModel>().fetchClients();
              },
            ),
          ],
        ),
        body: Consumer<ClientsViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (viewModel.clients.isEmpty) {
              return const Center(child: Text('No hay clientes registrados.'));
            } else {
              return ListView.builder(
                itemCount: viewModel.clients.length,
                itemBuilder: (context, index) {
                  final client = viewModel.clients[index];
                  return _buildClientCard(client, context);
                },
              );
            }
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showAddClientDialog(context),
          backgroundColor: Colors.cyan,
          child: const Icon(Icons.person_add),
        ),
      ),
    );
  }

  void _showAddClientDialog(BuildContext context) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _emailController = TextEditingController();
    final _phoneController = TextEditingController();
    String _statusValue = 'Potencial';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Añadir Nuevo Cliente'),
              content: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Nombre'),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, ingresa el nombre';
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: 'Teléfono'),
                      ),
                      const SizedBox(height: 16),
                      DropdownButtonFormField(
                        value: _statusValue,
                        decoration: const InputDecoration(labelText: 'Estado'),
                        items: ['Activo', 'Inactivo', 'Potencial']
                            .map((status) => DropdownMenuItem(
                                  value: status,
                                  child: Text(status),
                                ))
                            .toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _statusValue = newValue!;
                          });
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
                      final viewModel = context.read<ClientsViewModel>();
                      final newClient = Client(
                        name: _nameController.text,
                        email: _emailController.text,
                        phone: _phoneController.text,
                        status: _statusValue,
                      );
                      final success = await viewModel.addClient(newClient);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(success ? 'Cliente añadido con éxito' : 'Error al añadir el cliente'),
                            backgroundColor: success ? Colors.green : Colors.red,
                          ),
                        );
                      }
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
      _nameController.dispose();
      _emailController.dispose();
      _phoneController.dispose();
    });
  }

  Widget _buildClientCard(Client client, BuildContext context) {
    final isClientActive = client.status == 'Activo';
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isClientActive ? Colors.green[100] : Colors.grey[300],
          child: Icon(
            Icons.person_outline,
            color: isClientActive ? Colors.green : Colors.grey[600],
          ),
        ),
        title: Text(
          client.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${client.email}'),
            Text('Teléfono: ${client.phone}'),
          ],
        ),
        trailing: Text(
          client.status,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isClientActive ? Colors.green : Colors.orange,
          ),
        ),
        onTap: () {
          // TODO: Implementar un diálogo para ver/editar/eliminar cliente
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Detalles del cliente #${client.id}')),
          );
        },
      ),
    );
  }
}