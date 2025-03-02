import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LoRaGuard',
      theme: ThemeData(
        primaryColor: const Color(0xFF4285F4),
        scaffoldBackgroundColor: const Color(0xFF4285F4),
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF4285F4),
          primary: const Color(0xFF4285F4),
        ),
      ),
      home: const DashboardScreen(),
    );
  }
}
