import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:math';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  
  NotificationService._internal();
  
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  
  // Stream controller for notification taps
  final StreamController<String> _notificationTapController = StreamController<String>.broadcast();
  
  // Stream to listen for notification taps
  Stream<String> get onNotificationTap => _notificationTapController.stream;
  
  // Keys for shared preferences (must match those in settings_screen.dart)
  static const String _notificationsEnabledKey = 'notifications_enabled';
  static const String _alertTypeKey = 'alert_type';
  
  Future<void> initialize() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    final DarwinInitializationSettings initializationSettingsIOS = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          onDidReceiveLocalNotification: _onDidReceiveLocalNotification
        );
    
    final InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );
    
    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    
    // Request permissions for iOS
    await _requestPermissions();
    
    print('Notification service initialized');
  }
  
  Future<void> _requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }
  
  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    print('Notification tapped with payload: ${response.payload}');
    if (response.payload != null) {
      _notificationTapController.add(response.payload!);
    }
  }
  
  void _onDidReceiveLocalNotification(int id, String? title, String? body, String? payload) {
    print('iOS notification received: $title, $body, $payload');
    if (payload != null) {
      _notificationTapController.add(payload);
    }
  }
  
  Future<void> showNotification({
    int? id,
    required String title,
    required String body,
    String? payload,
  }) async {
    // Generate a random ID if none provided
    final notificationId = id ?? Random().nextInt(100000);
    
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
        androidNotificationDetails = AndroidNotificationDetails(
          'disaster_alerts',
          'Disaster Alerts',
          channelDescription: 'Urgent notifications about disaster events',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: false,
          fullScreenIntent: true, // Make notification more prominent
          category: AndroidNotificationCategory.alarm, // Mark as important alert
        );
        break;
      case 'Vibration':
        androidNotificationDetails = AndroidNotificationDetails(
          'disaster_alerts',
          'Disaster Alerts',
          channelDescription: 'Urgent notifications about disaster events',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
          enableVibration: true,
          vibrationPattern: Int64List.fromList(<int>[0, 500, 200, 500, 200, 500]), // Strong vibration pattern
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );
        break;
      case 'Silent':
        androidNotificationDetails = AndroidNotificationDetails(
          'disaster_alerts',
          'Disaster Alerts',
          channelDescription: 'Urgent notifications about disaster events',
          importance: Importance.max,
          priority: Priority.high,
          playSound: false,
          enableVibration: false,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );
        break;
      default:
        androidNotificationDetails = AndroidNotificationDetails(
          'disaster_alerts',
          'Disaster Alerts',
          channelDescription: 'Urgent notifications about disaster events',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: false,
          fullScreenIntent: true,
          category: AndroidNotificationCategory.alarm,
        );
    }
    
    final DarwinNotificationDetails iOSNotificationDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
      interruptionLevel: InterruptionLevel.timeSensitive, // High priority on iOS
    );
    
    final NotificationDetails notificationDetails = NotificationDetails(
      android: androidNotificationDetails,
      iOS: iOSNotificationDetails,
    );
    
    await _notificationsPlugin.show(
      notificationId,
      title,
      body,
      notificationDetails,
      payload: payload ?? 'map', // Default payload for navigation to map screen
    );
    
    print('Notification shown with alert type: $alertType, payload: $payload');
  }
  
  void dispose() {
    _notificationTapController.close();
  }
} 