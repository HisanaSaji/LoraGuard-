import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/navigation/app_navigation.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:lora2/features/alerts/data/mock_alert_repository.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_cubit.dart';
import 'package:lora2/features/alerts/presentation/screens/alerts_screen.dart';
import 'package:lora2/features/emergency/presentation/screens/emergency_screen.dart';
import 'package:lora2/features/map/presentation/screens/map_screen.dart';
import 'package:lora2/features/settings/presentation/screens/settings_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:lora2/core/providers/theme_provider.dart';
import 'package:lora2/core/theme/theme_cubit.dart';
import 'package:lora2/features/alerts/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service
  await NotificationService().initialize();
  
  try {
    print('Starting Firebase initialization...');
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyAOI4FeMWl7bwfu322Dj1uyuZbvKT7qfTo',
        appId: '1:932534568815:web:3e7a8fe28da55a7bb44a9a',
        messagingSenderId: '932534568815',
        projectId: 'loratest-76a91',
        authDomain: 'loratest-76a91.firebaseapp.com',
        databaseURL: 'https://loratest-76a91-default-rtdb.firebaseio.com',
        storageBucket: 'loratest-76a91.firebasestorage.app',
      ),
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const LoRaGuardApp(),
    ),
  );
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
            create: (context) => AlertCubit(
              context.read<AlertRepository>(),
            )..loadActiveAlerts(),
          ),
          BlocProvider<NavigationCubit>(
            create: (context) => NavigationCubit(),
          ),
          BlocProvider<ThemeCubit>(
            create: (context) => ThemeCubit(),
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
    return Scaffold(
      body: BlocBuilder<NavigationCubit, NavigationTab>(
        builder: (context, tab) {
          print('Current tab: ${tab.name}');
          return IndexedStack(
            index: tab.index,
            children: const [
              AlertsScreen(),
              EmergencyScreen(),
              MapScreen(),
              SettingsScreen(),
            ],
          );
        },
      ),
      bottomNavigationBar: const _BottomNavBar(),
    );
  }
}

class _BottomNavBar extends StatelessWidget {
  const _BottomNavBar();

  @override
  Widget build(BuildContext context) {
    final currentTab = context.watch<NavigationCubit>().state;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF000000),
        border: Border(
          top: BorderSide(
            color: Colors.grey[900]!,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _NavItem(
                icon: Icons.grid_view_rounded,
                label: 'Alerts',
                isSelected: currentTab == NavigationTab.alerts,
                onTap: () => _onTabSelected(context, NavigationTab.alerts),
              ),
              _NavItem(
                icon: Icons.emergency_rounded,
                label: 'Emergency',
                isSelected: currentTab == NavigationTab.emergency,
                onTap: () => _onTabSelected(context, NavigationTab.emergency),
              ),
              _NavItem(
                icon: Icons.map_rounded,
                label: 'Map',
                isSelected: currentTab == NavigationTab.map,
                onTap: () => _onTabSelected(context, NavigationTab.map),
              ),
              _NavItem(
                icon: Icons.settings_rounded,
                label: 'Settings',
                isSelected: currentTab == NavigationTab.settings,
                onTap: () => _onTabSelected(context, NavigationTab.settings),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _onTabSelected(BuildContext context, NavigationTab tab) {
    context.read<NavigationCubit>().setTab(tab);
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? const Color(0xFFFF4D32) : Colors.grey;
    
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color,
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
