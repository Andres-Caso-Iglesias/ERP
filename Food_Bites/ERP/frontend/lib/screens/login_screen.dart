/// @file login_screen.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Pantalla de inicio de sesión que permite a los usuarios autenticarse en el sistema.
library;

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:erp_food_bites/modules/auth/viewmodels/auth_viewmodel.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  bool _isLoginVisible = false;

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Uso extensión `read` para evitar la reconstrucción innecesaria del widget
      final authViewModel = context.read<AuthViewModel>();
      final success = await authViewModel.login(
        _usernameController.text,
        _passwordController.text,
      );

      if (!mounted) return;
      if (success) {
        // La navegación es manejada por el Consumer en main.dart
        // No es necesario llamar a Navigator.pushReplacement aquí
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenciales inválidas. Inténtalo de nuevo.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _toggleLoginVisibility() {
    setState(() {
      _isLoginVisible = !_isLoginVisible;
    });
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isSmallScreen = screenSize.width < 600;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 235, 235, 235),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 30.0, right: 30.0, bottom: 20.0),
                  child: Row(
                    children: [
                      Image.asset('assets/erp_logo.png', height: isSmallScreen ? 120 : 100),
                      if (!isSmallScreen) ...[
                        const SizedBox(width: 15),
                        const Text(
                          'Tu ERP Soluciones Empresariales',
                          style: TextStyle(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                      const Spacer(),
                      ElevatedButton(
                        onPressed: _toggleLoginVisibility,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepOrange,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                        ),
                        child: Text(
                          _isLoginVisible ? 'Cerrar' : 'Iniciar Sesión',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  height: screenSize.height * 0.4,
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    image: DecorationImage(
                      image: NetworkImage('https://via.placeholder.com/1200x400/F0F0F0/000000?text=ERP+Management'),
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Optimiza tu Negocio,\nSimplifica tu Gestión',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 40,
                        fontWeight: FontWeight.w900,
                        color: const Color.fromARGB(255, 92, 103, 255),
                        shadows: [
                          Shadow(
                            color: const Color.fromARGB(255, 32, 33, 36).withAlpha(127),
                            blurRadius: 10,
                            offset: const Offset(2, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'La Herramienta Definitiva para la Gestión Integral de tu Empresa',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Nuestro ERP está diseñado para centralizar todas las operaciones de tu negocio, desde ventas y contabilidad hasta inventario y recursos humanos. Con una interfaz intuitiva y potentes funcionalidades, te ayudamos a tomar decisiones inteligentes y a impulsar tu crecimiento.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black54,
                          height: 1.5,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                      const SizedBox(height: 30),
                      Wrap(
                        spacing: 20.0,
                        runSpacing: 20.0,
                        children: [
                          _buildFeatureCard(Icons.trending_up, 'Incrementa Ventas', 'Gestiona clientes y pedidos.'),
                          _buildFeatureCard(Icons.inventory, 'Control de Inventario', 'Optimiza existencias y reduce costes.'),
                          _buildFeatureCard(Icons.attach_money, 'Finanzas al Día', 'Automatiza la contabilidad y reportes.'),
                          _buildFeatureCard(Icons.group, 'Gestión de Personal', 'Administra RRHH desde un solo lugar.'),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20.0),
                  color: Colors.grey[200],
                  child: const Text(
                    '© 2025 Tu ERP. Todos los derechos reservados.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
          ),
          if (_isLoginVisible)
            Container(
              color: Colors.black.withAlpha(128),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
                child: AnimatedPositioned(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  top: _isLoginVisible ? screenSize.height / 2 - 200 : -500,
                  child: Card(
                    elevation: 8.0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                    child: Container(
                      width: 350,
                      padding: const EdgeInsets.all(24.0),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text('Accede a tu ERP', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                            const SizedBox(height: 25),
                            TextFormField(
                              controller: _usernameController,
                              decoration: InputDecoration(
                                labelText: 'Usuario',
                                hintText: 'ej. usuario@empresa.com',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                                prefixIcon: const Icon(Icons.person_outline),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) { if (value == null || value.isEmpty) return 'Introduce tu usuario'; return null; },
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: 'Contraseña',
                                hintText: '*************',
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0)),
                                prefixIcon: const Icon(Icons.lock_outline),
                                filled: true,
                                fillColor: Colors.grey[50],
                              ),
                              validator: (value) { if (value == null || value.isEmpty) return 'Introduce tu contraseña'; return null; },
                            ),
                            const SizedBox(height: 30),
                            ElevatedButton(
                              onPressed: _login,
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange, foregroundColor: Colors.white, minimumSize: const Size(double.infinity, 55), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)), elevation: 5),
                              child: const Text('Acceder', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 15),
                            TextButton(
                              onPressed: () { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Función de recuperación de contraseña no implementada.'))); },
                              child: const Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.deepOrange, fontSize: 14)),
                            ),
                            const SizedBox(height: 10),
                            TextButton(
                              onPressed: _toggleLoginVisibility,
                              child: const Text('Cerrar', style: TextStyle(color: Colors.grey, fontSize: 14)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }


  //widget para dar formato a las tarjetas
  Widget _buildFeatureCard(IconData icon, String title, String description) {
    return SizedBox(
      width: 300,
      child: Card(
        elevation: 4.0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 40, color: Colors.blueAccent),
              const SizedBox(height: 10),
              Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(description, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            ],
          ),
        ),
      ),
    );
  }
}