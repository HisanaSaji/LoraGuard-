import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:lora2/core/models/alert_model.dart';

part 'alert_state.freezed.dart';

@freezed
class AlertState with _$AlertState {
  const factory AlertState({
    @Default([]) List<AlertModel> alerts,
    @Default(true) bool isLoading,
    @Default(false) bool hasError,
    String? errorMessage,
  }) = _AlertState;

  factory AlertState.initial() => const AlertState(isLoading: true);
  
  factory AlertState.loading() => const AlertState(isLoading: true);
  
  factory AlertState.loaded(List<AlertModel> alerts) => AlertState(
        alerts: alerts,
        isLoading: false,
      );
  
  factory AlertState.error(String message) => AlertState(
        isLoading: false,
        hasError: true,
        errorMessage: message,
      );
} 