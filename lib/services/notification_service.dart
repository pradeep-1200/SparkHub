import 'dart:io' show Platform;

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission for notifications
    await _requestPermission();

    // Initialize local notifications
    await _initializeLocalNotifications();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle notification taps
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationTap);

    // Get FCM token
    final token = await _messaging.getToken();
    print('FCM Token: $token');
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );
    print('Notification permission: ${settings.authorizationStatus}');
  }

  Future<void> _initializeLocalNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(initSettings);
  }

  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Handling foreground message: ${message.messageId}');
    // Show local notification when app is in foreground
    await _showLocalNotification(message);
  }

  Future<void> _handleNotificationTap(RemoteMessage message) async {
    print('Handling notification tap: ${message.messageId}');
    // Handle navigation based on notification data
    _handleNotificationNavigation(message);
  }

  Future<void> _showLocalNotification(RemoteMessage message) async {
    const androidDetails = AndroidNotificationDetails(
      'sparkhub_channel',
      'SparkHub Notifications',
      channelDescription: 'Notifications for SparkHub events and updates',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _localNotifications.show(
      message.hashCode,
      message.notification?.title ?? 'SparkHub',
      message.notification?.body ?? 'New notification',
      notificationDetails,
      payload: message.data.toString(),
    );
  }

  void _handleNotificationNavigation(RemoteMessage message) {
    // Navigate based on notification type
    final data = message.data;
    if (data.containsKey('event_id')) {
      // Navigate to event details
      print('Navigate to event: ${data['event_id']}');
    } else if (data.containsKey('user_id')) {
      // Navigate to user profile
      print('Navigate to profile: ${data['user_id']}');
    }
  }

  Future<String?> getToken() async {
    return await _messaging.getToken();
  }

  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
  }

  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
  }
}

// Top-level function for background message handling
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
