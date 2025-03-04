import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/navigation/app_navigation.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:lora2/features/alerts/data/mock_alert_repository.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_cubit.dart';
import 'package:lora2/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:lora2/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:lora2/features/settings/presentation/screens/settings_screen.dart';

void main() {
  runApp(const LoRaGuardApp());
}

class LoRaGuardApp extends StatelessWidget {
  const LoRaGuardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AlertRepository>(
          create: (context) => MockAlertRepository(),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AlertCubit>(
            create: (context) => AlertCubit(context.read<AlertRepository>())..loadActiveAlerts(),
          ),
        ],
        child: MaterialApp(
          title: 'LoRaGuard',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          home: const AppShell(),
        ),
      ),
    );
  }
}

class AppShell extends StatelessWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context) {
    return AppNavigation(
      child: BlocBuilder<NavigationCubit, NavigationTab>(
        builder: (context, tab) {
          return IndexedStack(
            index: tab.index,
            children: const [
              AlertsScreen(),
              EmergencyScreen(),
              Scaffold(body: Center(child: Text('Map Screen', style: TextStyle(color: Colors.white)))),
              SettingsScreen(),
            ],
          );
        },
      ),
    );
  }
}
