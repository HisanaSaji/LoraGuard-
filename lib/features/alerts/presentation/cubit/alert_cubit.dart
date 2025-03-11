import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/models/alert_model.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_state.dart';
import 'dart:async';

class AlertCubit extends Cubit<AlertState> {
  final AlertRepository _repository;
  // Stream controller to notify about disaster alert deletions
  final _disasterDeletedController = StreamController<void>.broadcast();
  Stream<void> get onDisasterDeleted => _disasterDeletedController.stream;

  AlertCubit(this._repository) : super(AlertState.initial());
  
  @override
  Future<void> close() {
    _disasterDeletedController.close();
    return super.close();
  }

  Future<void> loadActiveAlerts() async {
    emit(AlertState.loading());
    try {
      final alerts = await _repository.getActiveAlerts();
      emit(AlertState.loaded(alerts));
    } catch (e) {
      emit(AlertState.error('Failed to load alerts: ${e.toString()}'));
    }
  }

  Future<void> loadAllAlerts() async {
    emit(AlertState.loading());
    try {
      final alerts = await _repository.getAllAlerts();
      emit(AlertState.loaded(alerts));
    } catch (e) {
      emit(AlertState.error('Failed to load alerts: ${e.toString()}'));
    }
  }
  
  Future<void> addAlert({
    required String location,
    required String description,
  }) async {
    try {
      await _repository.addAlert(
        location: location,
        description: description,
      );
      
      // Reload the active alerts to reflect the changes
      await loadActiveAlerts();
    } catch (e) {
      emit(AlertState.error('Failed to add alert: ${e.toString()}'));
    }
  }
  
  Future<void> deleteAlert(String id) async {
    try {
      await _repository.deleteAlert(id);
      
      // Notify listeners that a disaster alert was deleted
      _disasterDeletedController.add(null);
      
      // Reload the active alerts to reflect the changes
      await loadActiveAlerts();
    } catch (e) {
      emit(AlertState.error('Failed to delete alert: ${e.toString()}'));
    }
  }
} 