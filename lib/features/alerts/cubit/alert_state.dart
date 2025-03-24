import 'package:equatable/equatable.dart';
import 'package:lora2/features/alerts/models/alert_model.dart';

class AlertState extends Equatable {
  final List<AlertModel> alerts;
  final bool isLoading;
  final bool hasError;
  final String? errorMessage;
  final bool shouldNavigateToMap;

  const AlertState({
    this.alerts = const [],
    this.isLoading = false,
    this.hasError = false,
    this.errorMessage,
    this.shouldNavigateToMap = false,
  });

  AlertState copyWith({
    List<AlertModel>? alerts,
    bool? isLoading,
    bool? hasError,
    String? errorMessage,
    bool? shouldNavigateToMap,
  }) {
    return AlertState(
      alerts: alerts ?? this.alerts,
      isLoading: isLoading ?? this.isLoading,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage ?? this.errorMessage,
      shouldNavigateToMap: shouldNavigateToMap ?? this.shouldNavigateToMap,
    );
  }

  factory AlertState.initial() => const AlertState(isLoading: true);

  @override
  List<Object?> get props => [alerts, isLoading, hasError, errorMessage, shouldNavigateToMap];
} 