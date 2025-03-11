import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/core/services/weather_service.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:lora2/core/config/env_config.dart';
import 'package:lora2/core/navigation/app_navigation.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_cubit.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_state.dart';
import 'package:lora2/features/alerts/presentation/widgets/alert_card.dart';
import 'package:lora2/features/alerts/presentation/widgets/weather_card.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  WeatherData? _weatherData;
  bool _isLoadingWeather = true;
  String? _weatherError;
  
  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }
  
  Future<void> _fetchWeatherData() async {
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });
    
    try {
      final weatherService = WeatherService(apiKey: EnvConfig.openWeatherApiKey);
      final weatherData = await weatherService.getWeatherForCity('Thiruvananthapuram');
      
      setState(() {
        _weatherData = weatherData;
        _isLoadingWeather = false;
      });
    } catch (e) {
      setState(() {
        _weatherError = e.toString();
        _isLoadingWeather = false;
      });
      print('Error fetching weather data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            _buildWeatherSection(),
            _buildAlertTabs(),
            Expanded(
              child: _buildAlertsList(),
            ),
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
              color: AppTheme.primaryOrange,
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
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildWeatherSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Current Weather',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (_isLoadingWeather)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
                ),
              ),
            )
          else if (_weatherError != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'Failed to load weather data',
                style: TextStyle(color: Colors.red[300]),
              ),
            )
          else if (_weatherData != null)
            WeatherCard(weather: _weatherData!),
        ],
      ),
    );
  }

  Widget _buildAlertTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.primaryOrange,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Text(
          'Active Alerts',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList() {
    return BlocBuilder<AlertCubit, AlertState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryOrange),
            ),
          );
        }

        if (state.hasError) {
          return Center(
            child: SelectableText.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Error: ',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(
                    text: state.errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
            ),
          );
        }

        if (state.alerts.isEmpty) {
          return const Center(
            child: Text(
              'No alerts found',
              style: TextStyle(color: Colors.white70),
            ),
          );
        }

        return RefreshIndicator(
          color: AppTheme.primaryOrange,
          backgroundColor: AppTheme.darkGrey,
          onRefresh: () {
            _fetchWeatherData(); // Also refresh weather data
            return context.read<AlertCubit>().loadActiveAlerts();
          },
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final alert = state.alerts[index];
              return Dismissible(
                key: Key(alert.id),
                background: Container(
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (direction) {
                  // Delete the alert
                  context.read<AlertCubit>().deleteAlert(alert.id);
                  
                  // Show a snackbar
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Alert deleted'),
                      backgroundColor: AppTheme.darkGrey,
                      action: SnackBarAction(
                        label: 'UNDO',
                        textColor: AppTheme.primaryOrange,
                        onPressed: () {
                          // Reload alerts to restore the deleted alert
                          // In a real app, you would implement an undo feature
                          context.read<AlertCubit>().loadActiveAlerts();
                        },
                      ),
                    ),
                  );
                },
                child: AlertCard(
                  alert: alert,
                  onTap: () {
                    // Navigate to the map tab when alert is tapped
                    context.read<NavigationCubit>().setTab(NavigationTab.map);
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }
} 