import 'package:lora2/features/alerts/models/alert_model.dart';

abstract class AlertRepository {
  Future<List<AlertModel>> getAlerts();
  Future<void> deleteAlert(String id);
  Future<void> addAlert({required String location, required String description});
} 