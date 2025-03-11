import 'package:flutter/material.dart';
import 'package:lora2/core/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:lora2/core/providers/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;
  String _selectedAlertType = 'Sound';
  final String _appVersion = '1.0.0'; // Design mode version
  
  // Keys for shared preferences
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _alertTypeKey = 'alert_type';

  @override
  void initState() {
    super.initState();
    print('SettingsScreen - initState called');
    _loadPreferences();
  }
  
  // Load saved preferences
  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
        _selectedAlertType = prefs.getString(_alertTypeKey) ?? 'Sound';
      });
      print('Loaded preferences: notifications=$_notificationsEnabled, alertType=$_selectedAlertType');
    } catch (e) {
      print('Error loading preferences: $e');
    }
  }
  
  // Save preferences
  Future<void> _savePreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, _notificationsEnabled);
      await prefs.setString(_alertTypeKey, _selectedAlertType);
      print('Saved preferences: notifications=$_notificationsEnabled, alertType=$_selectedAlertType');
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    print('SettingsScreen - didChangeDependencies called');
  }

  @override
  Widget build(BuildContext context) {
    print('SettingsScreen - build called');
    return Scaffold(
      backgroundColor: AppTheme.pureBlack, // Ensure background color is set
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    _buildNotificationPreferences(),
                    const SizedBox(height: 32),
                    _buildAboutSection(),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16.0, 20.0, 16.0, 16.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTheme.darkGrey,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.settings_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationPreferences() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Notification Preferences',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SwitchListTile(
          title: const Text(
            'Enable Notifications',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          subtitle: const Text(
            'Receive alert notifications',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          value: _notificationsEnabled,
          activeColor: AppTheme.primaryOrange,
          onChanged: (value) {
            setState(() {
              _notificationsEnabled = value;
            });
            _savePreferences();
          },
        ),
        // Alert Type options
        if (_notificationsEnabled) ...[
          ListTile(
            leading: const Icon(Icons.notifications_active, color: Colors.grey),
            title: const Text(
              'Alert Type',
              style: TextStyle(color: Colors.white),
            ),
            trailing: DropdownButton<String>(
              value: _selectedAlertType,
              dropdownColor: AppTheme.darkGrey,
              style: const TextStyle(color: Colors.white),
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: Colors.grey),
              items: ['Sound', 'Vibration', 'Silent'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedAlertType = newValue;
                  });
                  _savePreferences();
                }
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAboutSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'About',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        ListTile(
          leading: const Icon(Icons.info_outline, color: Colors.grey),
          title: const Text(
            'App Version',
            style: TextStyle(color: Colors.white),
          ),
          trailing: Text(
            _appVersion,
            style: const TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
