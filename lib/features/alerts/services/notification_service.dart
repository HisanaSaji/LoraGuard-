import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Keys for shared preferences (must match those in settings_screen.dart)
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _alertTypeKey = 'alert_type';
  
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
    );
  }
  
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    // Get saved preferences
    final prefs = await SharedPreferences.getInstance();
    final notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    final alertType = prefs.getString(_alertTypeKey) ?? 'Sound';
    
    if (!notificationsEnabled) {
      print('Notifications are disabled. Skipping notification.');
      return;
    }
    
    // Configure notification based on alert type
    AndroidNotificationDetails androidNotificationDetails;
    
    switch (alertType) {
      case 'Sound':
        androidNotificationDetails = const AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel Description',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: false,
        );
        break;
      case 'Vibration':
        androidNotificationDetails = const AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel Description',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
        );
        break;
      case 'Silent':
        androidNotificationDetails = const AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel Description',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
          enableVibration: false,
        );
        break;
      default:
        androidNotificationDetails = const AndroidNotificationDetails(
          'channel_id',
          'Channel Name',
          channelDescription: 'Channel Description',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: false,
        );
    }
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
    );
    
    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
    );
    
    print('Notification shown with alert type: $alertType');
  }
} 