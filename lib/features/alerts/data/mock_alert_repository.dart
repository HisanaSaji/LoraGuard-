import 'package:lora2/core/models/alert_model.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:uuid/uuid.dart';

class MockAlertRepository implements AlertRepository {
  // Empty alerts list - removed all alert messages
  final List<AlertModel> _alerts = [];
  final _uuid = Uuid();

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
  
  @override
  Future<AlertModel> addAlert({
    required String location,
    required String description,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final alert = AlertModel(
      id: _uuid.v4(),
      location: location,
      description: description,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    _alerts.add(alert);
    return alert;
  }
  
  @override
  Future<void> deleteAlert(String id) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));
    
    final index = _alerts.indexWhere((alert) => alert.id == id);
    if (index != -1) {
      // Mark as deleted instead of removing from the list
      final alert = _alerts[index];
      _alerts[index] = alert.copyWith(isDeleted: true);
    }
  }
} 