import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lora2/core/models/alert_model.dart';

class AlertCard extends StatelessWidget {
  final AlertModel alert;
  final VoidCallback? onTap;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: _getAlertTypeColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getAlertTypeIcon(),
                      color: _getAlertTypeColor(),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getAlertTypeText(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        alert.location,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getSeverityColor().withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      _getSeverityText(),
                      style: TextStyle(
                        color: _getSeverityColor(),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                alert.description,
                style: TextStyle(
                  color: Colors.grey[800],
                  fontSize: 14,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _formatTimestamp(alert.timestamp),
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final formatter = DateFormat('MMM d, h:mm a');
    return formatter.format(timestamp);
  }

  Color _getSeverityColor() {
    switch (alert.severity) {
      case AlertSeverity.low:
        return Colors.green;
      case AlertSeverity.medium:
        return Colors.orange;
      case AlertSeverity.high:
        return Colors.blue;
      case AlertSeverity.critical:
        return Colors.red;
    }
  }

  String _getSeverityText() {
    switch (alert.severity) {
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

  IconData _getAlertTypeIcon() {
    switch (alert.type) {
      case AlertType.flood:
        return Icons.water_drop;
      case AlertType.earthquake:
        return Icons.warning;
      case AlertType.hurricane:
        return Icons.air;
      case AlertType.wildfire:
        return Icons.local_fire_department;
      case AlertType.tornado:
        return Icons.tornado;
      case AlertType.other:
        return Icons.warning_amber;
    }
  }

  Color _getAlertTypeColor() {
    switch (alert.type) {
      case AlertType.flood:
        return Colors.blue;
      case AlertType.earthquake:
        return Colors.red;
      case AlertType.hurricane:
        return Colors.orange;
      case AlertType.wildfire:
        return Colors.deepOrange;
      case AlertType.tornado:
        return Colors.purple;
      case AlertType.other:
        return Colors.grey;
    }
  }

  String _getAlertTypeText() {
    switch (alert.type) {
      case AlertType.flood:
        return 'FLOOD';
      case AlertType.earthquake:
        return 'EARTHQUAKE';
      case AlertType.hurricane:
        return 'HURRICANE';
      case AlertType.wildfire:
        return 'WILDFIRE';
      case AlertType.tornado:
        return 'TORNADO';
      case AlertType.other:
        return 'ALERT';
    }
  }
} 