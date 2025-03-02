import 'package:lora2/core/models/alert_model.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';

class MockAlertRepository implements AlertRepository {
  final List<AlertModel> _alerts = [
    AlertModel(
      id: '1',
      type: AlertType.flood,
      location: 'Riverside County, CA',
      description: 'Flash flooding reported in multiple areas. Roads are becoming impassable. Seek higher ground immediately.',
      timestamp: DateTime(2023, 5, 15, 14, 0),
      severity: AlertSeverity.high,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AlertModel(
      id: '2',
      type: AlertType.earthquake,
      location: 'San Francisco, CA',
      description: 'Magnitude 4.5 earthquake detected. Minor structural damage reported in some areas. Check for gas leaks and structural damage.',
      timestamp: DateTime(2023, 5, 15, 12, 45),
      severity: AlertSeverity.medium,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AlertModel(
      id: '3',
      type: AlertType.hurricane,
      location: 'Miami, FL',
      description: 'Hurricane approaching with winds exceeding 100mph. Evacuation orders in effect for coastal areas. Seek shelter immediately.',
      timestamp: DateTime(2023, 5, 15, 5, 15),
      severity: AlertSeverity.critical,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AlertModel(
      id: '4',
      type: AlertType.wildfire,
      location: 'Los Angeles County, CA',
      description: 'Wildfire spreading rapidly due to high winds. Evacuation orders in place for affected neighborhoods.',
      timestamp: DateTime(2023, 5, 14, 18, 30),
      severity: AlertSeverity.high,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    ),
    AlertModel(
      id: '5',
      type: AlertType.tornado,
      location: 'Oklahoma City, OK',
      description: 'Tornado warning in effect. Take shelter in a basement or interior room away from windows.',
      timestamp: DateTime(2023, 5, 14, 16, 0),
      severity: AlertSeverity.critical,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isDeleted: true,
    ),
  ];

  @override
  Future<List<AlertModel>> getActiveAlerts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _alerts.where((alert) => !alert.isDeleted).toList();
  }

  @override
  Future<List<AlertModel>> getAllAlerts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));
    return _alerts;
  }

  @override
  Future<AlertModel> getAlertById(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    return _alerts.firstWhere(
      (alert) => alert.id == id,
      orElse: () => throw Exception('Alert not found'),
    );
  }
} 