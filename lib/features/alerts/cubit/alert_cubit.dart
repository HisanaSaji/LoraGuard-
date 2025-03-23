class AlertCubit extends Cubit<AlertState> {
  AlertCubit() : super(const AlertState()) {
    print('AlertCubit: Initialized');
  }

  void addAlert({required String location, required String description}) {
    print('AlertCubit: Adding new alert for location: $location');
    final newAlert = Alert(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      location: location,
      description: description,
      timestamp: DateTime.now(),
    );
    
    emit(state.copyWith(
      alerts: [...state.alerts, newAlert],
    ));
    print('AlertCubit: Alert added successfully. Total alerts: ${state.alerts.length}');
  }

  void removeAlert(String id) {
    print('AlertCubit: Removing alert with id: $id');
    emit(state.copyWith(
      alerts: state.alerts.where((alert) => alert.id != id).toList(),
    ));
    print('AlertCubit: Alert removed successfully. Remaining alerts: ${state.alerts.length}');
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