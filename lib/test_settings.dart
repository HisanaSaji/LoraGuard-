import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:lora2/core/theme/theme_cubit.dart';
import 'package:lora2/features/settings/presentation/screens/settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ThemeCubit(),
      child: MaterialApp(
        title: 'Settings Test',
        theme: AppTheme.darkTheme,
        home: const SettingsScreen(),
      ),
    );
  }
} 