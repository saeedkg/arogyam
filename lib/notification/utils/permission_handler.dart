import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../service/fcm_service.dart';

/// Handler for notification permissions
class NotificationPermissionHandler {
  static const String _permissionAskedKey = 'notification_permission_asked';
  static const String _permissionDeniedKey = 'notification_permission_denied';

  /// Check if permission has been asked before
  static Future<bool> hasAskedForPermission() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionAskedKey) ?? false;
  }

  /// Mark permission as asked
  static Future<void> markPermissionAsked() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionAskedKey, true);
  }

  /// Check if permission was denied
  static Future<bool> wasPermissionDenied() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_permissionDeniedKey) ?? false;
  }

  /// Mark permission as denied
  static Future<void> markPermissionDenied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_permissionDeniedKey, true);
  }

  /// Clear permission denial status
  static Future<void> clearPermissionDenied() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_permissionDeniedKey);
  }

  /// Request notification permission
  static Future<bool> requestPermission() async {
    try {
      // Mark as asked
      await markPermissionAsked();

      // Request permission
      final settings = await FCMService.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('✅ Notification permission granted');
        await clearPermissionDenied();
        return true;
      } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
        print('⚠️ Notification provisional permission granted');
        await clearPermissionDenied();
        return true;
      } else {
        print('❌ Notification permission denied');
        await markPermissionDenied();
        return false;
      }
    } catch (e) {
      print('❌ Error requesting notification permission: $e');
      return false;
    }
  }

  /// Check current permission status
  static Future<AuthorizationStatus> checkPermissionStatus() async {
    return await FCMService.getPermissionStatus();
  }

  /// Check if should show permission rationale
  static Future<bool> shouldShowPermissionRationale() async {
    final hasAsked = await hasAskedForPermission();
    final wasDenied = await wasPermissionDenied();
    
    // Show rationale if never asked or if denied before
    return !hasAsked || wasDenied;
  }

  /// Request permission with rationale
  static Future<bool> requestPermissionWithRationale({
    required Function() onShowRationale,
    required Function() onPermissionGranted,
    required Function() onPermissionDenied,
  }) async {
    final shouldShowRationale = await shouldShowPermissionRationale();

    if (shouldShowRationale) {
      // Show rationale first
      onShowRationale();
    }

    // Request permission
    final granted = await requestPermission();

    if (granted) {
      onPermissionGranted();
    } else {
      onPermissionDenied();
    }

    return granted;
  }
}
