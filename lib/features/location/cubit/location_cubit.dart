import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_state.freezed.dart';

@freezed
class LocationState with _$LocationState {
  const factory LocationState({
    Position? currentPosition,
    @Default(false) bool isLoading,
    String? error,
  }) = _LocationState;
}

class LocationCubit extends Cubit<LocationState> {
  LocationCubit() : super(const LocationState());

  void updatePosition(Position position) {
    emit(state.copyWith(
      currentPosition: position,
      error: null,
    ));
  }

  void setError(String error) {
    emit(state.copyWith(
      error: error,
      isLoading: false,
    ));
  }

  void setLoading(bool loading) {
    emit(state.copyWith(isLoading: loading));
  }
} 