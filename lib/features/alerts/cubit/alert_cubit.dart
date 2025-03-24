import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/features/alerts/models/alert_model.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/cubit/alert_state.dart';

class AlertCubit extends Cubit<AlertState> {
  final AlertRepository _repository;

  AlertCubit(this._repository) : super(AlertState.initial()) {
    print('AlertCubit: Initialized');
    loadActiveAlerts();
  }

  Future<void> loadActiveAlerts() async {
    print('AlertCubit: Loading active alerts');
    emit(state.copyWith(isLoading: true, hasError: false));
    
    try {
      final alerts = await _repository.getAlerts();
      emit(state.copyWith(
        alerts: alerts,
        isLoading: false,
      ));
      print('AlertCubit: Loaded ${alerts.length} alerts');
    } catch (e) {
      print('AlertCubit: Error loading alerts: $e');
      emit(state.copyWith(
        isLoading: false,
        hasError: true,
        errorMessage: 'Failed to load alerts: $e',
      ));
    }
  }

  void addAlert({required String location, required String description}) {
    print('AlertCubit: Adding new alert for location: $location');
    final newAlert = AlertModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: location,
      description: description,
      timestamp: DateTime.now(),
      severity: 'info',
    );
    
    emit(state.copyWith(
      alerts: [...state.alerts, newAlert],
    ));
    print('AlertCubit: Alert added successfully. Total alerts: ${state.alerts.length}');
  }

  Future<void> deleteAlert(String id) async {
    print('AlertCubit: Removing alert with id: $id');
    try {
      // Update the state first for UI responsiveness
      final updatedAlerts = state.alerts.where((alert) => alert.id != id).toList();
      emit(state.copyWith(alerts: updatedAlerts));
      
      // Then update the repository
      await _repository.deleteAlert(id);
      print('AlertCubit: Alert removed successfully. Remaining alerts: ${updatedAlerts.length}');
    } catch (e) {
      print('AlertCubit: Error removing alert: $e');
      // Reload alerts to ensure UI is in sync with repository
      await loadActiveAlerts();
      emit(state.copyWith(
        hasError: true,
        errorMessage: 'Failed to remove alert: $e',
      ));
    }
  }

  void clearAlerts() {
    print('AlertCubit: Clearing all alerts');
    emit(state.copyWith(alerts: []));
    print('AlertCubit: All alerts cleared');
  }

  void navigateToMap() {
    print('AlertCubit: Triggering navigation to map');
    emit(state.copyWith(shouldNavigateToMap: true));
    print('AlertCubit: Navigation state updated');
  }

  void resetNavigation() {
    print('AlertCubit: Resetting navigation state');
    emit(state.copyWith(shouldNavigateToMap: false));
    print('AlertCubit: Navigation state reset');
  }
} 