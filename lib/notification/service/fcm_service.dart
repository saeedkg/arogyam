import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Top-level function for background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print('📩 Background message received');
  print('Title: ${message.notification?.title}');
  print('Body: ${message.notification?.body}');
  print('Data: ${message.data}');
}

/// Service for managing Firebase Cloud Messaging
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Initialize FCM
  static Future<void> initialize() async {
    // Request permission (iOS)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('✅ FCM permission granted');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      print('⚠️ FCM provisional permission granted');
    } else {
      print('❌ FCM permission denied');
    }

    // Get initial token
    String? token = await getToken();
    if (token != null) {
      print('✅ FCM Token: $token');
    }
  }

  /// Get FCM token
  static Future<String?> getToken() async {
    try {
      String? token = await _messaging.getToken();
      
      if (token != null) {
        // Save token locally
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('fcm_token', token);
      }
      
      return token;
    } catch (error) {
      print('❌ Error getting FCM token: $error');
      return null;
    }
  }

  /// Setup token refresh listener
  static void setupTokenRefreshListener(Function(String) onTokenRefresh) {
    _messaging.onTokenRefresh.listen((newToken) {
      print('🔄 FCM token refreshed: $newToken');
      
      // Save new token locally
      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('fcm_token', newToken);
      });
      
      // Call callback
      onTokenRefresh(newToken);
    });
  }

  /// Setup foreground message handler
  static void setupForegroundMessageHandler(Function(RemoteMessage)? onMessage) {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📩 Foreground message received');
      print('Title: ${message.notification?.title}');
      print('Body: ${message.notification?.body}');
      print('Data: ${message.data}');
      
      // Call callback if provided
      if (onMessage != null) {
        onMessage(message);
      }
    });
  }

  /// Setup background message handler
  static void setupBackgroundMessageHandler() {
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  }

  /// Setup notification tap handler
  static void setupNotificationTapHandler(Function(RemoteMessage) onTap) {
    // Handle notification tap when app is in background
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('📱 Notification tapped (background)');
      onTap(message);
    });

    // Handle notification tap when app is terminated
    _messaging.getInitialMessage().then((RemoteMessage? message) {
      if (message != null) {
        print('📱 Notification tapped (terminated)');
        onTap(message);
      }
    });
  }

  /// Request notification permissions
  static Future<NotificationSettings> requestPermission() async {
    return await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
  }

  /// Get permission status
  static Future<AuthorizationStatus> getPermissionStatus() async {
    NotificationSettings settings = await _messaging.getNotificationSettings();
    return settings.authorizationStatus;
  }

  /// Delete FCM token (for logout)
  static Future<void> deleteToken() async {
    try {
      await _messaging.deleteToken();
      print('✅ FCM token deleted');
    } catch (error) {
      print('❌ Error deleting FCM token: $error');
    }
  }
}
