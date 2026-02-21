import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import '../entities/device.dart';
import '../entities/notification_history_item.dart';
import '../entities/notification_preferences.dart';
import '../entities/notification_statistics.dart';
import '../entities/requests/device_registration_request.dart';
import '../entities/requests/device_settings_request.dart';
import '../entities/requests/notification_preference_request.dart';
import '../entities/requests/quiet_hours_request.dart';
import '../repository/notification_repository.dart';
import '../service/device_service.dart';
import '../service/fcm_service.dart';
import '../service/notification_service.dart';

class NotificationController extends GetxController {
  final NotificationRepository _repository;

  NotificationController(this._repository);

  // Observable state
  final RxList<Device> devices = <Device>[].obs;
  final RxList<NotificationHistoryItem> notificationHistory = <NotificationHistoryItem>[].obs;
  final Rx<NotificationPreferences?> preferences = Rx<NotificationPreferences?>(null);
  final Rx<NotificationStatistics?> statistics = Rx<NotificationStatistics?>(null);
  final RxBool isLoading = false.obs;
  final RxString currentDeviceId = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _initializeNotifications();
  }

  // ==================== Initialization ====================

  Future<void> _initializeNotifications() async {
    try {
      print('🔄 Initializing notifications...');
      
      // Get current device ID
      currentDeviceId.value = await DeviceService.getOrCreateDeviceId();
      
      print('✅ Notifications initialized');
    } catch (e) {
      print('❌ Error initializing notifications: $e');
    }
  }

  // ==================== Device Management ====================

  Future<bool> registerCurrentDevice() async {
    try {
      print('🔄 Registering current device...');
      
      // Get device ID
      final deviceId = await DeviceService.getOrCreateDeviceId();
      
      // Get device info
      final deviceInfo = await DeviceService.getDeviceInfo();
      
      // Get FCM token
      final fcmToken = await FCMService.getToken();
      
      if (fcmToken == null) {
        print('⚠️ No FCM token available, skipping registration');
        return false;
      }
      
      // Create registration request
      final request = DeviceRegistrationRequest(
        deviceId: deviceId,
        deviceName: deviceInfo['device_name'],
        deviceType: deviceInfo['device_type']!,
        deviceModel: deviceInfo['device_model'],
        deviceOsVersion: deviceInfo['device_os_version'],
        appVersion: deviceInfo['app_version'],
        fcmToken: fcmToken,
      );
      
      // Register with backend
      final response = await _repository.registerDevice(request);
      
      if (response.statusCode == 200) {
        print('✅ Device registered successfully');
        await DeviceService.markDeviceRegistered();
        currentDeviceId.value = deviceId;
        return true;
      }
      
      print('❌ Device registration failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('❌ Error registering device: $e');
      return false;
    }
  }

  Future<void> loadDevices() async {
    try {
      isLoading.value = true;
      
      final response = await _repository.getDevices(status: 'active');
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final devicesList = (data['devices'] as List)
            .map((json) => Device.fromJson(json))
            .toList();
        
        devices.value = devicesList;
        print('✅ Loaded ${devicesList.length} devices');
      }
    } catch (e) {
      print('❌ Error loading devices: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateDeviceSettings(
    String deviceId,
    DeviceSettingsRequest request,
  ) async {
    try {
      isLoading.value = true;
      
      final response = await _repository.updateDeviceSettings(deviceId, request);
      
      if (response.statusCode == 200) {
        print('✅ Device settings updated');
        await loadDevices();
      }
    } catch (e) {
      print('❌ Error updating device settings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> removeDevice(String deviceId) async {
    try {
      isLoading.value = true;
      
      final response = await _repository.removeDevice(deviceId);
      
      if (response.statusCode == 200) {
        print('✅ Device removed');
        await loadDevices();
      }
    } catch (e) {
      print('❌ Error removing device: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setPrimaryDevice(String deviceId) async {
    try {
      isLoading.value = true;
      
      final response = await _repository.setPrimaryDevice(deviceId);
      
      if (response.statusCode == 200) {
        print('✅ Primary device set');
        await loadDevices();
      }
    } catch (e) {
      print('❌ Error setting primary device: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Notification Preferences ====================

  Future<void> loadNotificationPreferences(String deviceId) async {
    try {
      isLoading.value = true;
      
      final response = await _repository.getNotificationPreferences(deviceId);
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        preferences.value = NotificationPreferences.fromJson(data['preferences']);
        print('✅ Notification preferences loaded');
      }
    } catch (e) {
      print('❌ Error loading notification preferences: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> updateNotificationPreference(
    String deviceId,
    String notificationType,
    bool enabled,
  ) async {
    try {
      final request = NotificationPreferenceRequest(
        notificationType: notificationType,
        enabled: enabled,
      );
      
      final response = await _repository.updateNotificationPreference(deviceId, request);
      
      if (response.statusCode == 200) {
        print('✅ Notification preference updated');
        await loadNotificationPreferences(deviceId);
      }
    } catch (e) {
      print('❌ Error updating notification preference: $e');
    }
  }

  Future<void> toggleSound(
    String deviceId,
    String notificationType,
    bool enabled,
  ) async {
    try {
      final request = NotificationPreferenceRequest(
        notificationType: notificationType,
        soundEnabled: enabled,
      );
      
      final response = await _repository.updateNotificationPreference(deviceId, request);
      
      if (response.statusCode == 200) {
        print('✅ Sound preference updated');
        await loadNotificationPreferences(deviceId);
      }
    } catch (e) {
      print('❌ Error updating sound preference: $e');
    }
  }

  Future<void> toggleVibration(
    String deviceId,
    String notificationType,
    bool enabled,
  ) async {
    try {
      final request = NotificationPreferenceRequest(
        notificationType: notificationType,
        vibrationEnabled: enabled,
      );
      
      final response = await _repository.updateNotificationPreference(deviceId, request);
      
      if (response.statusCode == 200) {
        print('✅ Vibration preference updated');
        await loadNotificationPreferences(deviceId);
      }
    } catch (e) {
      print('❌ Error updating vibration preference: $e');
    }
  }

  Future<void> setQuietHours(
    String deviceId,
    bool enabled,
    String? start,
    String? end,
  ) async {
    try {
      final request = QuietHoursRequest(
        enabled: enabled,
        start: start,
        end: end,
      );
      
      final response = await _repository.setQuietHours(deviceId, request);
      
      if (response.statusCode == 200) {
        print('✅ Quiet hours updated');
        await loadNotificationPreferences(deviceId);
      }
    } catch (e) {
      print('❌ Error updating quiet hours: $e');
    }
  }

  // ==================== Notification History ====================

  Future<void> loadNotificationHistory({Map<String, dynamic>? filters}) async {
    try {
      isLoading.value = true;
      
      final response = await _repository.getNotificationHistory(
        deviceId: filters?['device_id'],
        notificationType: filters?['notification_type'],
        status: filters?['status'],
        fromDate: filters?['from_date'],
        toDate: filters?['to_date'],
        page: filters?['page'] ?? 1,
        perPage: filters?['per_page'] ?? 20,
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        final historyList = (data['notifications'] as List)
            .map((json) => NotificationHistoryItem.fromJson(json))
            .toList();
        
        notificationHistory.value = historyList;
        print('✅ Loaded ${historyList.length} notifications');
      }
    } catch (e) {
      print('❌ Error loading notification history: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markNotificationAsClicked(String notificationId) async {
    try {
      final response = await _repository.markNotificationAsClicked(notificationId);
      
      if (response.statusCode == 200) {
        print('✅ Notification marked as clicked');
      }
    } catch (e) {
      print('❌ Error marking notification as clicked: $e');
    }
  }

  // ==================== Statistics ====================

  Future<void> loadStatistics({
    String? deviceId,
    String? fromDate,
    String? toDate,
  }) async {
    try {
      isLoading.value = true;
      
      final response = await _repository.getNotificationStatistics(
        deviceId: deviceId,
        fromDate: fromDate,
        toDate: toDate,
      );
      
      if (response.statusCode == 200) {
        final data = response.data['data'];
        statistics.value = NotificationStatistics.fromJson(data);
        print('✅ Statistics loaded');
      }
    } catch (e) {
      print('❌ Error loading statistics: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // ==================== Notification Handling ====================

  void handleForegroundNotification(RemoteMessage message) {
    print('📩 Handling foreground notification');
    
    // Show local notification
    NotificationService.showForegroundNotification(message);
  }

  void handleNotificationTap(RemoteMessage message) {
    print('📱 Handling notification tap');
    
    // Mark as clicked if notification ID is available
    if (message.data['notification_id'] != null) {
      markNotificationAsClicked(message.data['notification_id']);
    }
    
    // Navigation will be handled by notification_router.dart
  }

  // ==================== Testing ====================

  Future<void> sendTestNotification() async {
    try {
      final deviceId = currentDeviceId.value;
      
      if (deviceId.isEmpty) {
        print('❌ No device ID available');
        return;
      }
      
      final response = await _repository.sendTestNotification(
        deviceId,
        title: 'Test Notification',
        body: 'This is a test notification from Arogyam',
      );
      
      if (response.statusCode == 200) {
        print('✅ Test notification sent');
        Get.snackbar(
          'Success',
          'Test notification sent successfully',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      print('❌ Error sending test notification: $e');
      Get.snackbar(
        'Error',
        'Failed to send test notification',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }
}
