import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service for handling local notifications
class NotificationService {
  static final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  /// Initialize local notifications
  static Future<void> initialize() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create Android notification channel
    await _createAndroidNotificationChannel();

    print('✅ Local notifications initialized');
  }

  /// Create Android notification channel
  static Future<void> _createAndroidNotificationChannel() async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'high_importance_channel', // id
      'High Importance Notifications', // name
      description: 'This channel is used for important notifications.',
      importance: Importance.high,
      playSound: true,
      enableVibration: true,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Show foreground notification
  static Future<void> showForegroundNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;

    if (notification != null) {
      await _localNotifications.show(
        notification.hashCode,
        notification.title,
        notification.body,
        NotificationDetails(
          android: AndroidNotificationDetails(
            'high_importance_channel',
            'High Importance Notifications',
            channelDescription: 'This channel is used for important notifications.',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
            playSound: true,
            enableVibration: true,
          ),
          iOS: const DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        payload: jsonEncode(message.data),
      );

      // Save to history
      await saveNotificationToHistory(message);
    }
  }

  /// Handle notification tap
  static void _onNotificationTapped(NotificationResponse response) {
    print('📱 Notification tapped: ${response.payload}');
    
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!);
        // Handle navigation based on data
        // This will be implemented in notification_router.dart
      } catch (e) {
        print('❌ Error parsing notification payload: $e');
      }
    }
  }

  /// Save notification to local history
  static Future<void> saveNotificationToHistory(RemoteMessage message) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Get existing history
      List<String> history = prefs.getStringList('notification_history') ?? [];
      
      // Create notification item
      final notificationItem = {
        'id': message.messageId ?? DateTime.now().millisecondsSinceEpoch.toString(),
        'title': message.notification?.title ?? '',
        'body': message.notification?.body ?? '',
        'data': message.data,
        'received_at': DateTime.now().toIso8601String(),
        'status': 'delivered',
      };
      
      // Add to history (keep last 100)
      history.insert(0, jsonEncode(notificationItem));
      if (history.length > 100) {
        history = history.sublist(0, 100);
      }
      
      // Save back
      await prefs.setStringList('notification_history', history);
      
      print('✅ Notification saved to history');
    } catch (e) {
      print('❌ Error saving notification to history: $e');
    }
  }

  /// Get local notification history
  static Future<List<Map<String, dynamic>>> getLocalHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('notification_history') ?? [];
      
      return history.map((item) {
        return jsonDecode(item) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('❌ Error getting notification history: $e');
      return [];
    }
  }

  /// Clear notification history
  static Future<void> clearHistory() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('notification_history');
    print('🧹 Notification history cleared');
  }

  /// Mark notification as read
  static Future<void> markAsRead(String notificationId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> history = prefs.getStringList('notification_history') ?? [];
      
      // Find and update notification
      for (int i = 0; i < history.length; i++) {
        final item = jsonDecode(history[i]) as Map<String, dynamic>;
        if (item['id'] == notificationId) {
          item['status'] = 'read';
          item['read_at'] = DateTime.now().toIso8601String();
          history[i] = jsonEncode(item);
          break;
        }
      }
      
      await prefs.setStringList('notification_history', history);
      print('✅ Notification marked as read');
    } catch (e) {
      print('❌ Error marking notification as read: $e');
    }
  }

  /// Cancel all notifications
  static Future<void> cancelAll() async {
    await _localNotifications.cancelAll();
    print('🧹 All notifications cancelled');
  }
}
