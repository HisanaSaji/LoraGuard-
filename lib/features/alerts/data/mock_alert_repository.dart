import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/models/alert_model.dart';

class MockAlertRepository implements AlertRepository {
  final List<AlertModel> _alerts = [];
  AlertModel? _lastDeletedAlert;  // Add this to track last deleted alert

  @override
  Future<List<AlertModel>> getAlerts() async {
    print('MockAlertRepository: Getting alerts, count: ${_alerts.length}');
    return List.from(_alerts); // Return a copy of the list
  }

  @override
  Future<void> addAlert({required String location, required String description}) async {
    final newAlert = AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: location,
      description: description,
      timestamp: DateTime.now(),
      severity: 'info',
    );
    _alerts.add(newAlert);
    print('MockAlertRepository: Added new alert, total count: ${_alerts.length}');
  }

  @override
  Future<void> deleteAlert(String id) async {
    print('MockAlertRepository: Attempting to delete alert with id: $id');
    final alertIndex = _alerts.indexWhere((alert) => alert.id == id);
    if (alertIndex != -1) {
      _lastDeletedAlert = _alerts[alertIndex];
      _alerts.removeAt(alertIndex);
      print('MockAlertRepository: Alert deleted, remaining count: ${_alerts.length}');
    } else {
      print('MockAlertRepository: Alert not found for deletion');
    }
  }

  @override
  Future<void> restoreAlert(AlertModel alert) async {
    print('MockAlertRepository: Attempting to restore alert: ${alert.id}');
    if (!_alerts.any((a) => a.id == alert.id)) {
      _alerts.add(alert);
      print('MockAlertRepository: Alert restored, new count: ${_alerts.length}');
    } else {
      print('MockAlertRepository: Alert already exists, not restoring');
    }
  }
} 