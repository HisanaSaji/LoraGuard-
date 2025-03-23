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
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:provider/provider.dart';
import 'package:lora2/core/providers/theme_provider.dart';
import 'package:lora2/core/theme/theme_cubit.dart';
import 'package:lora2/features/alerts/services/notification_service.dart';
import 'dart:async';
import 'package:lora2/firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize notification service first
  final NotificationService notificationService = NotificationService();
  await notificationService.initialize();
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    print('Firebase initialized successfully');
  } catch (e) {
    print('Failed to initialize Firebase: $e');
  }

  // Initialize theme provider
  final themeProvider = ThemeProvider();
  // Simply create the theme provider without calling initialize if the method doesn't exist
  
  // Use MockAlertRepository instead of AlertRepository to avoid the abstract class error
  final alertRepository = MockAlertRepository();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>.value(
          value: themeProvider,
        ),
        Provider<AlertRepository>.value(
          value: alertRepository,
        ),
        Provider<NotificationService>.value(
          value: notificationService,
        ),
      ],
      child: const LoRaGuardApp(),
    ),
  );
}

class LoRaGuardApp extends StatefulWidget {
  const LoRaGuardApp({Key? key}) : super(key: key);

  @override
  State<LoRaGuardApp> createState() => _LoRaGuardAppState();
}

class _LoRaGuardAppState extends State<LoRaGuardApp> {
  StreamSubscription? _notificationSubscription;

  @override
  void initState() {
    super.initState();
    // Listen for notification taps
    _setupNotificationListeners();
  }

  void _setupNotificationListeners() {
    final notificationService = Provider.of<NotificationService>(context, listen: false);
    _notificationSubscription = notificationService.onNotificationTap.listen((String payload) {
      print('Notification tap received with payload: $payload');
      
      try {
        // Try to parse the payload as JSON first
        final Map<String, dynamic> payloadData = jsonDecode(payload);
        
        if (payloadData.containsKey('type') && payloadData['type'] == 'disaster') {
          print('Processing disaster notification tap');
          
          // Navigate to map tab
          final NavigationCubit navigationCubit = 
              BlocProvider.of<NavigationCubit>(context, listen: false);
          
          print('Navigating to map tab due to disaster notification tap');
          navigationCubit.setTab(NavigationTab.map);
          
          // Get latitude and longitude from payload if available
          if (payloadData.containsKey('latitude') && payloadData.containsKey('longitude')) {
            // This information could be passed to the map screen to center on this location
            // This would require a more sophisticated state management approach
            print('Disaster location: ${payloadData['latitude']}, ${payloadData['longitude']}');
            
            // We could also store this in a shared preferences or state provider
            // so the map can pick it up when it loads
            final prefs = SharedPreferences.getInstance();
            prefs.then((p) {
              p.setString('disaster_notification_location', 
                '${payloadData['latitude']},${payloadData['longitude']}');
              p.setString('disaster_notification_id', payloadData['id'] ?? '');
            });
          }
        }
      } catch (e) {
        // Handle legacy payload format
        print('Failed to parse notification payload as JSON: $e');
        
        if (payload.contains('map')) {
          // Get navigation cubit
          final NavigationCubit navigationCubit = 
              BlocProvider.of<NavigationCubit>(context, listen: false);
          
          // Use setTab instead of switchTab
          print('Navigating to map tab due to notification tap');
          navigationCubit.setTab(NavigationTab.map);
        }
      }
    });
  }

  @override
  void dispose() {
    _notificationSubscription?.cancel();
    super.dispose();
  }

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
          switch (tab) {
            case NavigationTab.alerts:
              return const AlertsScreen();
            case NavigationTab.emergency:
              return const EmergencyScreen();
            case NavigationTab.map:
              return const MapScreen();
            case NavigationTab.settings:
              return const SettingsScreen();
          }
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

class NavigationCubit extends Cubit<NavigationTab> {
  NavigationCubit() : super(NavigationTab.settings) {
    print('DEBUG: NavigationCubit initialized with tab: ${NavigationTab.settings}');
  }

  void setTab(NavigationTab tab) {
    print('DEBUG: Switching to tab: ${tab.name}');
    print('DEBUG: Previous tab was: ${state.name}');
    emit(tab);
    print('DEBUG: Tab switch complete');
  }
}
