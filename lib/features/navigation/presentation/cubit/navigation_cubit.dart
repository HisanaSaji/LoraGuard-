import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'navigation_state.freezed.dart';

@freezed
class NavigationState with _$NavigationState {
  const factory NavigationState({
    @Default(0) int currentIndex,
  }) = _NavigationState;
}

class NavigationCubit extends Cubit<NavigationState> {
  NavigationCubit() : super(const NavigationState()) {
    print('NavigationCubit initialized with index: ${state.currentIndex}');
  }

  void setIndex(int index) {
    print('NavigationCubit: Setting index from ${state.currentIndex} to $index');
    emit(state.copyWith(currentIndex: index));
  }
} 