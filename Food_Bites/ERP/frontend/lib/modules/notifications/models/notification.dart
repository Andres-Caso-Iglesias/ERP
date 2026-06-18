/// @file notification.dart
/// @author Andres Caso Iglesias
/// @date Septiembre 2025
/// @brief Define la estructura de datos para una notificación.
library;

import 'package:flutter/material.dart';

class AppNotification {
  final int id;
  final String title;
  final String description;
  final IconData icon;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    // Mapea el nombre del icono de la base de datos a un IconData
    IconData getIcon(String iconName) {
      switch (iconName) {
        case 'mail':
          return Icons.mail;
        case 'message':
          return Icons.message;
        case 'task':
          return Icons.task;
        case 'accounting':
          return Icons.account_balance_wallet;
        case 'inventory':
          return Icons.inventory;
        default:
          return Icons.info_outline;
      }
    }

    return AppNotification(
      id: json['id'] as int,
      title: json['title'] as String,
      description: json['description'] as String? ?? '',
      icon: getIcon(json['icon_name'] as String? ?? 'info'),
      isRead: json['is_read'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      // No se serializa el IconData, sino el nombre del icono para el backend
      'icon_name': icon == Icons.mail ? 'mail' : 'info',
      'is_read': isRead,
    };
  }

  // Método para crear una copia inmutable con nuevos valores
  AppNotification copyWith({
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title,
      description: description,
      icon: icon,
      isRead: isRead ?? this.isRead,
    );
  }
}