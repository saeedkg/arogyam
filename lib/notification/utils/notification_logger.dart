import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Logger for notification events
class NotificationLogger {
  static const String _logKey = 'notification_logs';
  static const int _maxLogs = 100;
  static bool _debugMode = false;

  /// Enable debug mode
  static void enableDebugMode() {
    _debugMode = true;
    print('🐛 Notification debug mode enabled');
  }

  /// Disable debug mode
  static void disableDebugMode() {
    _debugMode = false;
    print('🐛 Notification debug mode disabled');
  }

  /// Log device registration
  static void logDeviceRegistration(String deviceId, bool success) {
    final message = success
        ? '✅ Device registered: $deviceId'
        : '❌ Device registration failed: $deviceId';
    _log('DEVICE_REGISTRATION', message, {'device_id': deviceId, 'success': success});
  }

  /// Log token refresh
  static void logTokenRefresh(String? oldToken, String newToken) {
    final message = '🔄 FCM token refreshed';
    _log('TOKEN_REFRESH', message, {
      'old_token': oldToken?.substring(0, 20) ?? 'null',
      'new_token': newToken.substring(0, 20),
    });
  }

  /// Log notification received
  static void logNotificationReceived(String notificationType, {Map<String, dynamic>? data}) {
    final message = '📩 Notification received: $notificationType';
    _log('NOTIFICATION_RECEIVED', message, {
      'type': notificationType,
      'data': data,
    });
  }

  /// Log notification clicked
  static void logNotificationClicked(String notificationType, {Map<String, dynamic>? data}) {
    final message = '📱 Notification clicked: $notificationType';
    _log('NOTIFICATION_CLICKED', message, {
      'type': notificationType,
      'data': data,
    });
  }

  /// Log error
  static void logError(String operation, dynamic error, {StackTrace? stackTrace}) {
    final message = '❌ Error in $operation: $error';
    _log('ERROR', message, {
      'operation': operation,
      'error': error.toString(),
      'stack_trace': stackTrace?.toString(),
    });
  }

  /// Log API call
  static void logApiCall(String endpoint, int statusCode, {dynamic response}) {
    final message = '🌐 API call: $endpoint - Status: $statusCode';
    _log('API_CALL', message, {
      'endpoint': endpoint,
      'status_code': statusCode,
      'response': response,
    });
  }

  /// Log permission request
  static void logPermissionRequest(String status) {
    final message = '🔐 Permission request: $status';
    _log('PERMISSION', message, {'status': status});
  }

  /// Internal log method
  static void _log(String type, String message, Map<String, dynamic> data) {
    // Always print in debug mode
    if (_debugMode) {
      print('[$type] $message');
      print('Data: ${jsonEncode(data)}');
    }

    // Save to persistent storage
    _saveLog(type, message, data);
  }

  /// Save log to persistent storage
  static Future<void> _saveLog(String type, String message, Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList(_logKey) ?? [];

      final logEntry = {
        'timestamp': DateTime.now().toIso8601String(),
        'type': type,
        'message': message,
        'data': data,
      };

      logs.insert(0, jsonEncode(logEntry));

      // Keep only last N logs
      if (logs.length > _maxLogs) {
        logs = logs.sublist(0, _maxLogs);
      }

      await prefs.setStringList(_logKey, logs);
    } catch (e) {
      print('❌ Error saving log: $e');
    }
  }

  /// Get all logs
  static Future<List<Map<String, dynamic>>> getLogs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<String> logs = prefs.getStringList(_logKey) ?? [];

      return logs.map((log) {
        return jsonDecode(log) as Map<String, dynamic>;
      }).toList();
    } catch (e) {
      print('❌ Error getting logs: $e');
      return [];
    }
  }

  /// Clear all logs
  static Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_logKey);
    print('🧹 Notification logs cleared');
  }

  /// Export logs as JSON string
  static Future<String> exportLogs() async {
    final logs = await getLogs();
    return jsonEncode(logs);
  }

  /// Get logs by type
  static Future<List<Map<String, dynamic>>> getLogsByType(String type) async {
    final logs = await getLogs();
    return logs.where((log) => log['type'] == type).toList();
  }

  /// Get recent logs (last N)
  static Future<List<Map<String, dynamic>>> getRecentLogs(int count) async {
    final logs = await getLogs();
    return logs.take(count).toList();
  }
}
