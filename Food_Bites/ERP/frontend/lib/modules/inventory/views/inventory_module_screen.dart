/// @file inventory_module_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene los widgets de la interfaz de usuario para la pantalla de gestión de inventario.
library;

import 'package:erp_food_bites/modules/inventory/models/inventory_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/inventory/viewmodels/inventory_viewmodel.dart';

class InventoryModuleScreen extends StatefulWidget {
  const InventoryModuleScreen({super.key});

  @override
  State<InventoryModuleScreen> createState() => _InventoryModuleScreenState();
}

class _InventoryModuleScreenState extends State<InventoryModuleScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _quantityController = TextEditingController();
  final _priceController = TextEditingController();
  final _categoryController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _quantityController.dispose();
    _priceController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  void _resetFormFields() {
    _nameController.clear();
    _quantityController.clear();
    _priceController.clear();
    _categoryController.clear();
  }

  void _showProductDialog({Product? productToEdit}) {
    if (productToEdit != null) {
      _nameController.text = productToEdit.productName;
      _quantityController.text = productToEdit.quantity.toString();
      _priceController.text = productToEdit.price.toStringAsFixed(2);
      _categoryController.text = productToEdit.category;
    } else {
      _resetFormFields();
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(productToEdit == null ? 'Añadir Nuevo Producto' : 'Modificar Producto'),
          content: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Nombre del Producto'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa el nombre';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _quantityController,
                    decoration: const InputDecoration(labelText: 'Cantidad'),
                    keyboardType: TextInputType.number,
                    inputFormatters: <TextInputFormatter>[
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una cantidad';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _priceController,
                    decoration: const InputDecoration(labelText: 'Precio'),
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    validator: (value) {
                      if (value == null || value.isEmpty || double.tryParse(value) == null) {
                        return 'Por favor, ingresa un precio válido';
                      }
                      return null;
                    },
                  ),
                  TextFormField(
                    controller: _categoryController,
                    decoration: const InputDecoration(labelText: 'Categoría'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor, ingresa una categoría';
                      }
                      return null;
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
                  final viewModel = context.read<InventoryViewModel>();
                  final product = Product(
                    id: productToEdit?.id,
                    productName: _nameController.text,
                    quantity: int.parse(_quantityController.text),
                    price: double.parse(_priceController.text),
                    category: _categoryController.text,
                  );

                  bool success;
                  if (productToEdit == null) {
                    success = await viewModel.addProduct(product);
                    if (!context.mounted) return;
                    _showSnackBar(success ? 'Producto añadido correctamente' : 'Error al añadir el producto', isError: !success);
                  } else {
                    success = await viewModel.updateProduct(product);
                    if (!context.mounted) return;
                    _showSnackBar(success ? 'Producto modificado correctamente' : 'Error al modificar el producto', isError: !success);
                  }
                  Navigator.of(context).pop();
                }
              },
              child: Text(productToEdit == null ? 'Guardar' : 'Modificar'),
            ),
          ],
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
        title: const Text('Módulo de Inventario'),
        backgroundColor: Colors.indigo,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InventoryViewModel>().fetchProducts(),
          ),
        ],
      ),
      body: Consumer<InventoryViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.isLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (viewModel.errorMessage != null) {
            return Center(child: Text(viewModel.errorMessage!));
          } else if (viewModel.products.isEmpty) {
            return const Center(child: Text('No hay productos en inventario.'));
          } else {
            return ListView.builder(
              itemCount: viewModel.products.length,
              itemBuilder: (context, index) {
                final product = viewModel.products[index];
                return _buildProductCard(product, context);
              },
            );
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showProductDialog(),
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add_shopping_cart),
      ),
    );
  }

  Widget _buildProductCard(Product product, BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 4,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: Colors.indigo,
          child: Icon(Icons.shopping_bag_outlined, color: Colors.white),
        ),
        title: Text(
          product.productName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cantidad: ${product.quantity}'),
            Text('Categoría: ${product.category}'),
          ],
        ),
        trailing: SizedBox(
          width: 150,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '€${product.price.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.blue),
                onPressed: () => _showProductDialog(productToEdit: product),
              ),
              IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () async {
                  if (product.id == null) {
                    _showSnackBar('No se puede eliminar un producto sin ID', isError: true);
                    return;
                  }
                  final bool confirmDelete = await _showDeleteConfirmationDialog(context);
                  if (confirmDelete) {
                    final viewModel = Provider.of<InventoryViewModel>(context, listen: false);
                    final success = await viewModel.deleteProduct(product.id!);
                    if (!context.mounted) return;
                    _showSnackBar(success ? 'Producto eliminado correctamente' : 'Error al eliminar el producto', isError: !success);
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Diálogo de confirmación para eliminar un producto
Future<bool> _showDeleteConfirmationDialog(BuildContext context) async {
  return await showDialog<bool>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: const Text('Confirmar Eliminación'),
        content: const Text('¿Estás seguro de que deseas eliminar este producto?'),
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