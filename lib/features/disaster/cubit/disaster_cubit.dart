import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'disaster_state.freezed.dart';

@freezed
class DisasterState with _$DisasterState {
  const factory DisasterState({
    @Default(false) bool isDisasterDetected,
    String? localArea,
    String? city,
  }) = _DisasterState;
}

class DisasterCubit extends Cubit<DisasterState> {
  DisasterCubit() : super(const DisasterState());

  void setDisasterStatus({
    required bool isDetected,
    String? localArea,
    String? city,
  }) {
    emit(DisasterState(
      isDisasterDetected: isDetected,
      localArea: localArea,
      city: city,
    ));
  }

  void clearDisaster() {
    emit(const DisasterState());
  }
} 