import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/models/alert_model.dart';

class MockAlertRepository implements AlertRepository {
  final List<AlertModel> _alerts = [];

  @override
  Future<List<AlertModel>> getAlerts() async {
    return _alerts;
  }

  @override
  Future<void> addAlert({required String location, required String description}) async {
    _alerts.add(AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: location,
      description: description,
      timestamp: DateTime.now(),
      severity: 'info',
    ));
  }

  @override
  Future<void> deleteAlert(String id) async {
    _alerts.removeWhere((alert) => alert.id == id);
  }
} 