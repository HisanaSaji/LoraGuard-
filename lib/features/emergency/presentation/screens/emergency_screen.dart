import 'package:flutter/material.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatelessWidget {
  const EmergencyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.pureBlack,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Emergency',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              _buildEmergencyCard(
                context,
                'Call Emergency',
                '📞',
                'Immediately connect with emergency services',
                AppTheme.primaryOrange,
                onTap: () => _makeEmergencyCall(),
              ),
              const SizedBox(height: 16),
              _buildEmergencyCard(
                context,
                'Send SOS',
                '🚨',
                'Send your location to emergency contacts',
                Colors.red,
                onTap: () => _sendSOS(context),
              ),
              const SizedBox(height: 16),
              _buildEmergencyCard(
                context,
                'Emergency Contacts',
                '📋',
                'View and manage emergency contacts',
                Colors.blue,
                onTap: () => _viewEmergencyContacts(context),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmergencyCard(
    BuildContext context,
    String title,
    String emoji,
    String description,
    Color color, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppTheme.darkGrey,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 32),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: color,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _makeEmergencyCall() async {
    final Uri url = Uri.parse('tel:112');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }

  void _sendSOS(BuildContext context) {
    // TODO: Implement SOS functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sending SOS signal with your location...'),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _viewEmergencyContacts(BuildContext context) {
    // TODO: Navigate to emergency contacts screen
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Opening emergency contacts...'),
        backgroundColor: Colors.blue,
      ),
    );
  }
} 