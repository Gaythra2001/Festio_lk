import 'package:flutter/foundation.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String type; // 'booking', 'event', 'reminder', 'message'
  final DateTime timestamp;
  bool isRead;
  final String? actionUrl;
  final String? iconData;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.timestamp,
    this.isRead = false,
    this.actionUrl,
    this.iconData,
  });
}

class NotificationProvider with ChangeNotifier {
  final List<NotificationModel> _notifications = [];
  bool _notificationsEnabled = true;

  List<NotificationModel> get notifications => _notifications;
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();
  int get unreadCount => unreadNotifications.length;
  bool get notificationsEnabled => _notificationsEnabled;

  // Add a new notification
  void addNotification({
    required String title,
    required String message,
    required String type,
    String? actionUrl,
    String? iconData,
  }) {
    final notification = NotificationModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      message: message,
      type: type,
      timestamp: DateTime.now(),
      isRead: false,
      actionUrl: actionUrl,
      iconData: iconData,
    );

    _notifications.insert(0, notification);
    notifyListeners();
  }

  // Mark notification as read
  void markAsRead(String notificationId) {
    final index =
        _notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _notifications[index].isRead = true;
      notifyListeners();
    }
  }

  // Mark all notifications as read
  void markAllAsRead() {
    for (var notification in _notifications) {
      notification.isRead = true;
    }
    notifyListeners();
  }

  // Delete notification
  void deleteNotification(String notificationId) {
    _notifications.removeWhere((n) => n.id == notificationId);
    notifyListeners();
  }

  // Clear all notifications
  void clearAllNotifications() {
    _notifications.clear();
    notifyListeners();
  }

  // Toggle notifications
  void toggleNotifications() {
    _notificationsEnabled = !_notificationsEnabled;
    notifyListeners();
  }

  // Simulate notifications (for demo purposes)
  void addBookingConfirmation(String eventTitle) {
    addNotification(
      title: 'Booking Confirmed',
      message: 'Your booking for $eventTitle has been confirmed!',
      type: 'booking',
      iconData: 'check_circle',
    );
  }

  void addEventReminder(String eventTitle) {
    addNotification(
      title: 'Event Reminder',
      message: '$eventTitle starts in 1 hour',
      type: 'reminder',
      iconData: 'notifications_active',
    );
  }

  void addNewEventNotification(String eventTitle) {
    addNotification(
      title: 'New Event Available',
      message: 'A new event $eventTitle matching your interests is now available',
      type: 'event',
      iconData: 'event',
    );
  }

  void addSystemNotification(String title, String message) {
    addNotification(
      title: title,
      message: message,
      type: 'message',
      iconData: 'info',
    );
  }
}
