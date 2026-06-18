/// @file main.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Punto de entrada de la aplicación, responsable de iniciar la interfaz de usuario, definir las rutas y la configuración de temas.
library;

import 'package:erp_food_bites/modules/accounting/viewmodels/accounting_viewmodel.dart';
import 'package:erp_food_bites/modules/auth/viewmodels/auth_viewmodel.dart';
import 'package:erp_food_bites/modules/clients/viewmodels/clients_viewmodel.dart';
import 'package:erp_food_bites/modules/inventory/viewmodels/inventory_viewmodel.dart';
import 'package:erp_food_bites/modules/notifications/viewmodels/notifications_viewmodel.dart';
import 'package:erp_food_bites/modules/sales/viewmodels/sales_viewmodel.dart';
import 'package:erp_food_bites/screens/main_dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:erp_food_bites/screens/login_screen.dart';
import 'package:provider/provider.dart'; 
void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => AuthViewModel()),
        ChangeNotifierProvider(create: (context) => ClientsViewModel()),
        ChangeNotifierProvider(create: (context) => InventoryViewModel()),
        ChangeNotifierProvider(create: (context) => SalesViewModel()),
        ChangeNotifierProvider(create: (context) => AccountingViewModel()),
        ChangeNotifierProvider(create: (context) => NotificationsViewModel()),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ERP Food Bites',
      theme: ThemeData(
        primarySwatch: Colors.deepOrange,
        fontFamily: 'CabinetGrotesk-Light',
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: Consumer<AuthViewModel>(
        builder: (context, authViewModel, child) {
          if (authViewModel.isAuthenticated) {
            return const MainDashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}