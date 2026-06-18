// @file pos_module_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene los widgets de la interfaz de usuario para la pantalla de punto de venta.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/pos/viewmodels/pos_viewmodel.dart';
import 'package:erp_food_bites/modules/pos/models/product.dart';

class POSModuleScreen extends StatelessWidget {
  const POSModuleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width > 600;

    return ChangeNotifierProvider(
      create: (context) => POSViewModel(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Punto de Venta'),
          backgroundColor: Colors.blueAccent,
        ),
        body: Consumer<POSViewModel>(
          builder: (context, viewModel, child) {
            if (viewModel.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            return isLargeScreen
                ? _buildLargeScreenLayout(context, viewModel)
                : _buildSmallScreenLayout(context, viewModel);
          },
        ),
      ),
    );
  }

  Widget _buildLargeScreenLayout(BuildContext context, POSViewModel viewModel) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Productos Disponibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                Expanded(
                  child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 8.0,
                      mainAxisSpacing: 8.0,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: viewModel.availableProducts.length,
                    itemBuilder: (context, index) {
                      final product = viewModel.availableProducts[index];
                      return _buildProductCard(context, product, viewModel);
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Carrito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  Expanded(
                    child: ListView.builder(
                      itemCount: viewModel.cart.length,
                      itemBuilder: (context, index) {
                        final product = viewModel.cart.keys.elementAt(index);
                        final quantity = viewModel.cart.values.elementAt(index);
                        return _buildCartItem(context, product, quantity, viewModel);
                      },
                    ),
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: €${viewModel.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: viewModel.cart.isEmpty
                                ? null
                                : () async {
                                    final success = await viewModel.processSale();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success ? 'Venta procesada con éxito' : 'Error al procesar la venta',
                                          ),
                                          backgroundColor: success ? Colors.green : Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.payment),
                            label: const Text('Procesar Venta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSmallScreenLayout(BuildContext context, POSViewModel viewModel) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Productos Disponibles', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const Divider(),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 8.0,
                    mainAxisSpacing: 8.0,
                    childAspectRatio: 0.8,
                  ),
                  itemCount: viewModel.availableProducts.length,
                  itemBuilder: (context, index) {
                    final product = viewModel.availableProducts[index];
                    return _buildProductCard(context, product, viewModel);
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            color: Colors.grey[200],
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Carrito', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  const Divider(),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: viewModel.cart.length,
                    itemBuilder: (context, index) {
                      final product = viewModel.cart.keys.elementAt(index);
                      final quantity = viewModel.cart.values.elementAt(index);
                      return _buildCartItem(context, product, quantity, viewModel);
                    },
                  ),
                  const Divider(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total: €${viewModel.totalAmount.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: viewModel.cart.isEmpty
                                ? null
                                : () async {
                                    final success = await viewModel.processSale();
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            success ? 'Venta procesada con éxito' : 'Error al procesar la venta',
                                          ),
                                          backgroundColor: success ? Colors.green : Colors.red,
                                        ),
                                      );
                                    }
                                  },
                            icon: const Icon(Icons.payment),
                            label: const Text('Procesar Venta'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(BuildContext context, Product product, POSViewModel viewModel) {
    final isOutOfStock = product.stock == 0;
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: InkWell(
        onTap: isOutOfStock ? null : () => viewModel.addProductToCart(product),
        borderRadius: BorderRadius.circular(10),
        child: Opacity(
          opacity: isOutOfStock ? 0.5 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_bag_outlined, size: 50, color: Colors.blueAccent),
              const SizedBox(height: 8),
              Text(
                product.name,
                textAlign: TextAlign.center,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 4),
              Text(
                '€${product.price.toStringAsFixed(2)}',
                style: const TextStyle(fontSize: 16, color: Colors.green),
              ),
              const SizedBox(height: 4),
              Text(
                'Stock: ${product.stock}',
                style: TextStyle(
                  color: product.stock <= 5 ? Colors.red : Colors.grey,
                  fontWeight: product.stock <= 5 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              if (isOutOfStock)
                const Text(
                  'Sin Stock',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCartItem(BuildContext context, Product product, int quantity, POSViewModel viewModel) {
    return ListTile(
      title: Text(product.name),
      subtitle: Text('€${product.price.toStringAsFixed(2)} x $quantity'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.remove_circle, color: Colors.red),
            onPressed: () => viewModel.removeProductFromCart(product),
          ),
          IconButton(
            icon: const Icon(Icons.add_circle, color: Colors.green),
            onPressed: () => viewModel.addProductToCart(product),
          ),
        ],
      ),
    );
  }
}