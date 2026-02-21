import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';

/// Service for managing device identification and information
class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static const String _deviceRegisteredKey = 'device_registered';
  static const String _deviceRegisteredAtKey = 'device_registered_at';
  static const String _fcmTokenKey = 'fcm_token';

  /// Get or create device ID (generated once, stored forever)
  static Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Check if device_id already exists
    String? deviceId = prefs.getString(_deviceIdKey);
    
    if (deviceId == null) {
      // Generate new UUID
      deviceId = const Uuid().v4();
      
      // Save permanently
      await prefs.setString(_deviceIdKey, deviceId);
      print('✅ New device ID generated: $deviceId');
    } else {
      print('✅ Existing device ID found: $deviceId');
    }
    
    return deviceId;
  }

  /// Get device information
  static Future<Map<String, String>> getDeviceInfo() async {
    final deviceInfo = DeviceInfoPlugin();
    final packageInfo = await PackageInfo.fromPlatform();
    
    if (Platform.isIOS) {
      final iosInfo = await deviceInfo.iosInfo;
      return {
        'device_name': iosInfo.name, // "John's iPhone"
        'device_type': 'ios',
        'device_model': iosInfo.model, // "iPhone"
        'device_os_version': iosInfo.systemVersion, // "17.1"
        'app_version': packageInfo.version, // "1.0.0"
      };
    } else if (Platform.isAndroid) {
      final androidInfo = await deviceInfo.androidInfo;
      return {
        'device_name': androidInfo.model, // "SM-G998B"
        'device_type': 'android',
        'device_model': androidInfo.model, // "SM-G998B"
        'device_os_version': androidInfo.version.release, // "13"
        'app_version': packageInfo.version, // "1.0.0"
      };
    }
    
    return {
      'device_name': 'Unknown',
      'device_type': 'unknown',
      'device_model': 'Unknown',
      'device_os_version': 'Unknown',
      'app_version': packageInfo.version,
    };
  }

  /// Check if device is registered
  static Future<bool> isDeviceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_deviceRegisteredKey) ?? false;
  }

  /// Mark device as registered
  static Future<void> markDeviceRegistered() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_deviceRegisteredKey, true);
    await prefs.setString(_deviceRegisteredAtKey, DateTime.now().toIso8601String());
    print('✅ Device marked as registered');
  }

  /// Clear registration status (for testing)
  static Future<void> clearRegistrationStatus() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceRegisteredKey);
    await prefs.remove(_deviceRegisteredAtKey);
    print('🧹 Registration status cleared');
  }

  /// Get stored FCM token
  static Future<String?> getStoredFCMToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fcmTokenKey);
  }

  /// Save FCM token locally
  static Future<void> saveFCMToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fcmTokenKey, token);
    print('✅ FCM token saved locally');
  }
}
