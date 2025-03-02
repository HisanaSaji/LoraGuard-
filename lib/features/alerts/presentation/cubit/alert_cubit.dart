import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_state.dart';

class AlertCubit extends Cubit<AlertState> {
  final AlertRepository _repository;

  AlertCubit(this._repository) : super(AlertState.initial());

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
} 