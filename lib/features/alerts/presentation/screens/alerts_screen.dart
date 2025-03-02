import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_cubit.dart';
import 'package:lora2/features/alerts/presentation/cubit/alert_state.dart';
import 'package:lora2/features/alerts/presentation/widgets/alert_card.dart';

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
    return BlocBuilder<AlertCubit, AlertState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(
            child: CircularProgressIndicator(),
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
            child: Text('No alerts found'),
          );
        }

        return RefreshIndicator(
          onRefresh: () => context.read<AlertCubit>().loadActiveAlerts(),
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: state.alerts.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final alert = state.alerts[index];
              return AlertCard(
                alert: alert,
                onTap: () {
                  // Navigate to alert details
                },
              );
            },
          ),
        );
      },
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