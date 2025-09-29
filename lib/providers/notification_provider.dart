import 'package:flutter/material.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationProvider extends ChangeNotifier {
  final NotificationService _notificationService = NotificationService();
  
  List<NotificationModel> _notifications = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _fcmToken;

  // Getters
  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications => 
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get fcmToken => _fcmToken;

  // Initialize notifications
  Future<void> initialize() async {
    try {
      await _notificationService.initialize();
      _fcmToken = await _notificationService.getToken();
      _clearError();
    } catch (e) {
      _setError('Failed to initialize notifications: ${e.toString()}');
    }
  }

  // Add notification
  void addNotification(NotificationModel notification) {
    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index = _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // Mark all as read
  void markAllAsRead() {
    for (int i = 0; i < _notifications.length; i++) {
      if (!_notifications[i].isRead) {
        _notifications[i] = _notifications[i].copyWith(
          isRead: true,
          readAt: DateTime.now(),
        );
      }
    }
    notifyListeners();
  }

  // Remove notification
  void removeNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Subscribe to topic
  Future<void> subscribeToTopic(String topic) async {
    try {
      await _notificationService.subscribeToTopic(topic);
      _clearError();
    } catch (e) {
      _setError('Failed to subscribe to topic: ${e.toString()}');
    }
  }

  // Unsubscribe from topic
  Future<void> unsubscribeFromTopic(String topic) async {
    try {
      await _notificationService.unsubscribeFromTopic(topic);
      _clearError();
    } catch (e) {
      _setError('Failed to unsubscribe from topic: ${e.toString()}');
    }
  }

  // Create local notification
  void createNotification({
    required String title,
    required String body,
    NotificationType type = NotificationType.general,
    Map<String, dynamic>? data,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      type: type,
      data: data ?? {},
      createdAt: DateTime.now(),
    );
    
    addNotification(notification);
  }

  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }
}
