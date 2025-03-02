import 'package:flutter/material.dart';

enum AlertType { flood, earthquake, hurricane }

enum AlertSeverity { low, medium, high, critical }

class Alert {
  final AlertType type;
  final AlertSeverity severity;
  final String location;
  final String description;
  final DateTime timestamp;

  const Alert({
    required this.type,
    required this.severity,
    required this.location,
    required this.description,
    required this.timestamp,
  });

  String get severityText {
    switch (severity) {
      case AlertSeverity.low:
        return 'Low';
      case AlertSeverity.medium:
        return 'Medium';
      case AlertSeverity.high:
        return 'High';
      case AlertSeverity.critical:
        return 'Critical';
    }
  }

  Color get severityColor {
    switch (severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.grey;
      case AlertSeverity.high:
        return const Color(0xFF4285F4);
      case AlertSeverity.critical:
        return Colors.red.shade200;
    }
  }

  IconData get typeIcon {
    switch (type) {
      case AlertType.flood:
        return Icons.water_drop;
      case AlertType.earthquake:
        return Icons.warning;
      case AlertType.hurricane:
        return Icons.air;
    }
  }

  Color get typeColor {
    switch (type) {
      case AlertType.flood:
        return const Color(0xFF5C8AA9);
      case AlertType.earthquake:
        return Colors.red;
      case AlertType.hurricane:
        return Colors.orange;
    }
  }
} 