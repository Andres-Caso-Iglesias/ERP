/// @file main_dashboard_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Pantalla principal que muestra el panel de control con un resumen de todos los módulos del ERP una vez loggeado.
library;

import 'package:flutter/material.dart';
import 'package:erp_food_bites/modules/accounting/views/accounting_module_screen.dart';
import 'package:erp_food_bites/modules/clients/views/clients_module_screen.dart';
import 'package:erp_food_bites/modules/human_resources/views/human_resources_module_screen.dart';
import 'package:erp_food_bites/modules/pos/views/pos_module_screen.dart';
import 'package:erp_food_bites/modules/purchases/views/purchases_module_screen.dart';
import 'package:erp_food_bites/modules/reports/views/reports_module_screen.dart';
import 'package:erp_food_bites/modules/sales/views/sales_module_screen.dart';
import 'package:erp_food_bites/modules/inventory/views/inventory_module_screen.dart';

class MainDashboardScreen extends StatelessWidget {
  const MainDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Determina si es una pantalla grande (web/tablet)
    final isLargeScreen = MediaQuery.of(context).size.width > 900;
  
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: Row(
          children: [
            // Logo a la izquierda
            Image.asset(
              'assets/erp_logo.png', 
              height: 40,
            ),
            const SizedBox(width: 10),
            const Text(
              'Mi ERP',
              style: TextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          //usuario a la derecha
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: CircleAvatar(
              backgroundImage: const AssetImage('assets/perfil.jpg'),
              radius: 40,
              backgroundColor: Colors.blueGrey[100],
            ),
          ),
        ],
      ),
      body: isLargeScreen
          ? _buildTwoColumnLayout(context) // Diseño pantallas grandes
          : _buildSmallScreenLayout(context), // Diseño pantallas pequeñas
    );
  }

  // Diseño para pantallas grandes (web/tablet)
  Widget _buildTwoColumnLayout(BuildContext context) {
    return Row(
      children: [
        // Columna izquierda: correos, mensajes, tareas y cosas así
        Expanded(
          flex: 1, // Ocupa menos espacio
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(right: BorderSide(color: Colors.grey[300]!, width: 1.0)),
            ),
            child: const Column(
              children: [
                _CommunicationSection(
                  title: 'Correos Recientes',
                  icon: Icons.mail,
                  items: ['Correo 1', 'Correo 2', 'Correo 3'],
                ),
                SizedBox(height: 20),
                _CommunicationSection(
                  title: 'Mensajes Pendientes',
                  icon: Icons.message,
                  items: ['Mensaje de Soporte', 'Recordatorio de Cliente'],
                ),
                SizedBox(height: 20),
                _CommunicationSection(
                  title: 'Mis Tareas',
                  icon: Icons.task,
                  items: ['Preparar Informe Q3', 'Reunión con Cliente X'],
                ),
              ],
            ),
          ),
        ),
        // Columna derecha: Módulos ERP + Redes Sociales/Estadísticas
        Expanded(
          flex: 3, // Ocupa la mayor parte del espacio
          child: Column(
            children: [
              // Parte superior derecha: Módulos Instalados del ERP
              Expanded(
                flex: 2, // Ocupa 2/3 del espacio vertical de la derecha
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Módulos Instalados',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Divider(),
                      Expanded(
                        child: GridView.count(
                          crossAxisCount: 4, // 4 módulos por fila
                          crossAxisSpacing: 16.0,
                          mainAxisSpacing: 16.0,
                          //todos los modulos a mostrar (mas adelante dependera si estan seleccionados)
                          children: [
                            _buildModuleCard(context, Icons.point_of_sale, 'Ventas',
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesModuleScreen()))),
                            _buildModuleCard(context, Icons.warehouse, 'Inventario',
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryModuleScreen()))),
                            _buildModuleCard(context, Icons.shopping_cart, 'Compras',
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchasesModuleScreen()))),
                            _buildModuleCard(context, Icons.account_balance, 'Contabilidad', 
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountingModuleScreen()))),
                            _buildModuleCard(context, Icons.people, 'Clientes',
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsModuleScreen()))),
                            _buildModuleCard(context, Icons.analytics, 'Informes',
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsModuleScreen()))),
                            _buildModuleCard(context, Icons.store, 'Punto de Venta',
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const POSModuleScreen()))),
                            _buildModuleCard(context, Icons.group, 'RR.HH.',
                              () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HumanResourcesModuleScreen()))),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Parte inferior derecha: Redes Sociales y Estadísticas
              Expanded(
                flex: 1, // Ocupa 1/3 del espacio vertical de la derecha
                child: Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.blueGrey[50],
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Información y Estadísticas',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _StatisticCard(
                              title: 'Ventas Hoy',
                              value: '1.250 €',
                              icon: Icons.trending_up,
                              color: Colors.green,
                            ),
                            _StatisticCard(
                              title: 'Nuevos Clientes',
                              value: '15',
                              icon: Icons.person_add,
                              color: Colors.blue,
                            ),
                            _StatisticCard(
                              title: 'Tareas Pendientes',
                              value: '7',
                              icon: Icons.pending_actions,
                              color: Colors.orange,
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
        ),
      ],
    );
  }

  // Diseño para pantallas pequeñas (móviles) - Simplificado
  Widget _buildSmallScreenLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Módulos Instalados
          const Text(
            'Módulos ERP',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          GridView.count(
            shrinkWrap: true, // Para que el GridView ocupe solo el espacio necesario
            physics: const NeverScrollableScrollPhysics(), // Evitar scroll anidado
            crossAxisCount: 2, // 2 columnas en móvil
            crossAxisSpacing: 16.0,
            mainAxisSpacing: 16.0,
            children: [
              _buildModuleCard(context, Icons.point_of_sale, 'Ventas',
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SalesModuleScreen()))),
              _buildModuleCard(context, Icons.warehouse, 'Inventario',
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const InventoryModuleScreen()))),
              _buildModuleCard(context, Icons.shopping_cart, 'Compras', 
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PurchasesModuleScreen()))),
              _buildModuleCard(context, Icons.account_balance, 'Contabilidad', 
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const AccountingModuleScreen()))),
              _buildModuleCard(context, Icons.people, 'Clientes',
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ClientsModuleScreen()))),
              _buildModuleCard(context, Icons.analytics, 'Informes',
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ReportsModuleScreen()))),
              _buildModuleCard(context, Icons.store, 'Punto de Venta',
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const POSModuleScreen()))),
              _buildModuleCard(context, Icons.group, 'RR.HH.',
                () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HumanResourcesModuleScreen()))),
            ],
          ),
          const SizedBox(height: 30),

          // Comunicaciones
          const Text(
            'Comunicaciones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          const _CommunicationSection(
            title: 'Correos Recientes',
            icon: Icons.mail,
            items: ['Correo 1', 'Correo 2', 'Correo 3'],
          ),
          const SizedBox(height: 20),
          const _CommunicationSection(
            title: 'Mensajes Pendientes',
            icon: Icons.message,
            items: ['Mensaje de Soporte', 'Recordatorio de Cliente'],
          ),
          const SizedBox(height: 20),
          const _CommunicationSection(
            title: 'Mis Tareas',
            icon: Icons.task,
            items: ['Preparar Informe Q3', 'Reunión con Cliente X'],
          ),
          const SizedBox(height: 30),

          // Estadísticas
          const Text(
            'Estadísticas Clave',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Divider(),
          Row(
            children: [
              _StatisticCard(
                title: 'Ventas Hoy',
                value: '1.250 €',
                icon: Icons.trending_up,
                color: Colors.green,
              ),
              _StatisticCard(
                title: 'Nuevos Clientes',
                value: '15',
                icon: Icons.person_add,
                color: Colors.blue,
              ),
              _StatisticCard(
                title: 'Tareas Pendientes',
                value: '7',
                icon: Icons.pending_actions,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  //tarjetas de módulo 
  Widget _buildModuleCard(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return Card(
      elevation: 4.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 50.0, // Tamaño para el grid
              color: Theme.of(context).primaryColor,
            ),
            const SizedBox(height: 8.0),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 14.0, // Tamaño ajustado
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Widgets Auxiliares para el Dashboard ---

class _CommunicationSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<String> items;

  const _CommunicationSection({
    required this.title,
    required this.icon,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 10.0),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const Divider(),
            if (items.isEmpty)
              const Text('No hay elementos pendientes.')
            else
              ...items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Text('- $item'),
                  )),
          ],
        ),
      ),
    );
  }
}

class _StatisticCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatisticCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Card(
        elevation: 3.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 30, color: color),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );
  }
}