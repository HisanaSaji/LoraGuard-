import 'package:lora2/core/models/alert_model.dart';

abstract class AlertRepository {
  Future<List<AlertModel>> getActiveAlerts();
  Future<List<AlertModel>> getAllAlerts();
  Future<AlertModel> getAlertById(String id);
  Future<AlertModel> addAlert({
    required String location,
    required String description,
  });
  Future<void> deleteAlert(String id);
} 