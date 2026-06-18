/// @file notifications_viewmodel.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Contiene la lógica de negocio para la gestión de notificaciones.
library;

import 'package:erp_food_bites/config/config.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/notification.dart';

class NotificationsViewModel extends ChangeNotifier {
  bool _isLoading = false;
  List<AppNotification> _notifications = [];
  String? _errorMessage;

  bool get isLoading => _isLoading;
  List<AppNotification> get notifications => _notifications;
  String? get errorMessage => _errorMessage;

  // URL en config.dart
  final String _baseUrl = '$kBaseUrl/notifications';

  NotificationsViewModel() {
    fetchNotifications();
  }

  Future<void> fetchNotifications() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse(_baseUrl));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        _notifications = data.map((json) => AppNotification.fromJson(json)).toList();
        debugPrint('Notificaciones cargadas con éxito.');
      } else {
        debugPrint('Error al cargar notificaciones: ${response.statusCode}');
        _errorMessage = 'No se pudieron cargar las notificaciones. Código de error: ${response.statusCode}';
        _notifications = _fetchMockNotifications();
      }
    } catch (e) {
      debugPrint('Error de conexión: $e');
      _errorMessage = 'Error de conexión. Verifica tu red.';
      _notifications = _fetchMockNotifications();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Marca una notificación específica como leída.
  Future<bool> markAsRead(int id) async {
    try {
      final response = await http.put(
        Uri.parse('$_baseUrl/$id/mark-as-read'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final index = _notifications.indexWhere((notification) => notification.id == id);
        if (index != -1) {
          _notifications[index] = _notifications[index].copyWith(isRead: true);
          notifyListeners();
        }
        return true;
      } else {
        debugPrint('Error al marcar como leída: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Error de conexión al marcar como leída: $e');
      return false;
    }
  }

  /// Proporciona datos de ejemplo.
  List<AppNotification> _fetchMockNotifications() {
    return [
      AppNotification(
        id: 1,
        title: 'Pedido Recibido',
        description: 'Se ha recibido un nuevo pedido de la mesa 5.',
        icon: Icons.fastfood,
        isRead: false,
      ),
      AppNotification(
        id: 2,
        title: 'Nivel Bajo de Inventario',
        description: 'El stock de harina está por debajo del mínimo.',
        icon: Icons.warning_amber,
        isRead: false,
      ),
      AppNotification(
        id: 3,
        title: 'Mensaje de Proveedor',
        description: 'Su pedido ha sido enviado y llegará mañana.',
        icon: Icons.local_shipping,
        isRead: true,
      ),
      AppNotification(
        id: 4,
        title: 'Pago Recibido',
        description: 'Se ha procesado un pago de 150€ de un cliente.',
        icon: Icons.account_balance_wallet,
        isRead: false,
      ),
    ];
  }
}