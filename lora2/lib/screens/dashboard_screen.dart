import 'package:flutter/material.dart';
import '../components/alert_card.dart';
import '../models/alert.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for alerts
    final List<Alert> alerts = [
      Alert(
        type: AlertType.flood,
        severity: AlertSeverity.high,
        location: 'Riverside County, CA',
        description: 'Flash flooding reported in multiple areas. Roads are beco...',
        timestamp: DateTime(2024, 5, 15, 14, 0),
      ),
      Alert(
        type: AlertType.earthquake,
        severity: AlertSeverity.medium,
        location: 'San Francisco, CA',
        description: 'Magnitude 4.5 earthquake detected. Minor structural dam...',
        timestamp: DateTime(2024, 5, 15, 12, 45),
      ),
      Alert(
        type: AlertType.hurricane,
        severity: AlertSeverity.critical,
        location: 'Miami, FL',
        description: 'Hurricane approaching with winds exceeding 100mph. Evac...',
        timestamp: DateTime(2024, 5, 15, 5, 15),
      ),
    ];

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'LoRaGuard Dashboard',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Active Alerts',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: alerts.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16.0),
                    child: AlertCard(alert: alerts[index]),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Theme.of(context).primaryColor,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alerts',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
} 