import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:lora2/features/alerts/data/mock_alert_repository.dart';
import 'package:lora2/features/alerts/domain/alert_repository.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_cubit.dart';
import 'package:lora2/features/alerts/presentation/screens/alerts_screen.dart';

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
          theme: AppTheme.lightTheme,
          home: const AlertsScreen(),
        ),
      ),
    );
  }
}

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildAlertTabs(),
            Expanded(
              child: _buildAlertsList(),
            ),
            _buildBottomNavBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.blue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.shield_outlined,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'LoRaGuard',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          const Icon(Icons.notifications_outlined, size: 28),
        ],
      ),
    );
  }

  Widget _buildAlertTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text(
              'Active Alerts',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const Spacer(),
          Row(
            children: [
              const Text(
                'View All',
                style: TextStyle(
                  color: Colors.blue,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Icon(
                Icons.arrow_forward,
                size: 16,
                color: Colors.blue,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        AlertCard(
          type: 'FLOOD',
          location: 'Riverside County, CA',
          description: 'Flash flooding reported in multiple areas. Roads are beco...',
          time: 'May 15, 2:00 PM',
          severity: 'High',
          icon: Icons.water_drop,
          color: Colors.blue,
        ),
        SizedBox(height: 16),
        AlertCard(
          type: 'EARTHQUAKE',
          location: 'San Francisco, CA',
          description: 'Magnitude 4.5 earthquake detected. Minor structural dam...',
          time: 'May 15, 12:45 PM',
          severity: 'Medium',
          icon: Icons.warning,
          color: Colors.red,
        ),
        SizedBox(height: 16),
        AlertCard(
          type: 'HURRICANE',
          location: 'Miami, FL',
          description: 'Hurricane approaching with winds exceeding 100mph. Evac...',
          time: 'May 15, 5:15 AM',
          severity: 'Critical',
          icon: Icons.air,
          color: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.grid_view, true),
          _buildNavItem(Icons.notifications_outlined, false),
          _buildNavItem(Icons.map_outlined, false),
          _buildNavItem(Icons.settings_outlined, false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, bool isSelected) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: isSelected ? Colors.grey[200] : Colors.transparent,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey,
      ),
    );
  }
}

class AlertCard extends StatelessWidget {
  final String type;
  final String location;
  final String description;
  final String time;
  final String severity;
  final IconData icon;
  final Color color;

  const AlertCard({
    super.key,
    required this.type,
    required this.location,
    required this.description,
    required this.time,
    required this.severity,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      type,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      location,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getSeverityColor(severity).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    severity,
                    style: TextStyle(
                      color: _getSeverityColor(severity),
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              description,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                time,
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'high':
        return Colors.blue;
      case 'medium':
        return Colors.orange;
      case 'critical':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
