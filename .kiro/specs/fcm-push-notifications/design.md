# Design Document

## Overview

This document outlines the technical design for implementing Firebase Cloud Messaging (FCM) push notifications in the Arogyam Flutter application. The system will integrate with the existing backend API to provide real-time notifications for healthcare events, support multi-device management, and offer granular notification preferences.

The design follows the existing project architecture using GetX for state management, Dio for networking, and the established AROGYAMAPI pattern for API communication.

## Architecture

### High-Level Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     Flutter Application                      │
├─────────────────────────────────────────────────────────────┤
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │ Notification │  │   Device     │  │     FCM      │     │
│  │   Settings   │  │ Management   │  │   Handler    │     │
│  │     UI       │  │      UI      │  │              │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                  │              │
│  ┌──────▼─────────────────▼──────────────────▼───────┐     │
│  │         Notification Controller (GetX)             │     │
│  └──────┬─────────────────┬──────────────────┬────────┘     │
│         │                 │                  │              │
│  ┌──────▼───────┐  ┌──────▼───────┐  ┌──────▼───────┐     │
│  │ Notification │  │    Device    │  │     FCM      │     │
│  │   Service    │  │   Service    │  │   Service    │     │
│  └──────┬───────┘  └──────┬───────┘  └──────┬───────┘     │
│         │                 │                  │              │
│  ┌──────▼─────────────────▼──────────────────▼───────┐     │
│  │         Notification Repository                    │     │
│  └──────┬──────────────────────────────────────────────┘     │
│         │                                                   │
│  ┌──────▼──────────────────────────────────────────────┐     │
│  │              AROGYAMAPI (Dio)                       │     │
│  └──────┬──────────────────────────────────────────────┘     │
└─────────┼─────────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────────┐
│                    Backend API Server                        │
│  /api/v1/{role}/devices/*                                   │
│  /api/v1/{role}/notifications/*                             │
└─────────────────────────────────────────────────────────────┘
```

### Component Interaction Flow

```
App Launch
    │
    ├─> Initialize Firebase
    │
    ├─> Initialize FCM Service
    │       │
    │       ├─> Request Permissions
    │       ├─> Get FCM Token
    │       └─> Setup Listeners
    │
    └─> Check Auth Status
            │
            ├─> If Authenticated
            │       │
            │       ├─> Get/Create Device ID
            │       ├─> Register Device
            │       └─> Setup Notification Handlers
            │
            └─> If Not Authenticated
                    └─> Wait for Login
```

## Components and Interfaces

### 1. Core Services

#### 1.1 FCMService

Handles all Firebase Cloud Messaging operations.

```dart
class FCMService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  
  // Initialize FCM and request permissions
  static Future<void> initialize();
  
  // Get current FCM token
  static Future<String?> getToken();
  
  // Setup token refresh listener
  static void setupTokenRefreshListener(Function(String) onTokenRefresh);
  
  // Setup foreground message handler
  static void setupForegroundMessageHandler();
  
  // Setup background message handler
  static void setupBackgroundMessageHandler();
  
  // Setup notification tap handler
  static void setupNotificationTapHandler(Function(RemoteMessage) onTap);
  
  // Request notification permissions
  static Future<NotificationSettings> requestPermission();
  
  // Check permission status
  static Future<AuthorizationStatus> getPermissionStatus();
}
```

#### 1.2 DeviceService

Manages device identification and information.

```dart
class DeviceService {
  // Get or create unique device ID (UUID)
  static Future<String> getOrCreateDeviceId();
  
  // Get device information (name, type, model, OS version)
  static Future<Map<String, String>> getDeviceInfo();
  
  // Check if device is registered
  static Future<bool> isDeviceRegistered();
  
  // Mark device as registered
  static Future<void> markDeviceRegistered();
  
  // Clear registration status
  static Future<void> clearRegistrationStatus();
  
  // Get stored FCM token
  static Future<String?> getStoredFCMToken();
  
  // Save FCM token locally
  static Future<void> saveFCMToken(String token);
}
```

#### 1.3 NotificationService

Handles notification display and local management.

```dart
class NotificationService {
  // Initialize local notifications
  static Future<void> initialize();
  
  // Show foreground notification
  static Future<void> showForegroundNotification(RemoteMessage message);
  
  // Handle notification tap
  static void handleNotificationTap(RemoteMessage message);
  
  // Save notification to local history
  static Future<void> saveNotificationToHistory(RemoteMessage message);
  
  // Get local notification history
  static Future<List<NotificationHistoryItem>> getLocalHistory();
  
  // Clear notification history
  static Future<void> clearHistory();
  
  // Mark notification as read
  static Future<void> markAsRead(String notificationId);
}
```

### 2. Repository Layer

#### 2.1 NotificationRepository

Handles all API communication for notifications and devices.

```dart
class NotificationRepository {
  final AROGYAMAPI _api;
  
  // Device Management
  Future<APIResponse> registerDevice(DeviceRegistrationRequest request);
  Future<APIResponse> getDevices({String? status, String? deviceType});
  Future<APIResponse> getDeviceDetails(String deviceId);
  Future<APIResponse> updateDeviceSettings(String deviceId, DeviceSettingsRequest request);
  Future<APIResponse> removeDevice(String deviceId);
  Future<APIResponse> setPrimaryDevice(String deviceId);
  Future<APIResponse> refreshFCMToken(String deviceId, String fcmToken);
  
  // Notification Preferences
  Future<APIResponse> getNotificationPreferences(String deviceId);
  Future<APIResponse> updateNotificationPreference(String deviceId, NotificationPreferenceRequest request);
  Future<APIResponse> setQuietHours(String deviceId, QuietHoursRequest request);
  Future<APIResponse> bulkUpdatePreferences(String deviceId, List<NotificationPreferenceRequest> preferences);
  
  // Notification History
  Future<APIResponse> getNotificationHistory({
    String? deviceId,
    String? notificationType,
    String? status,
    String? fromDate,
    String? toDate,
    int page = 1,
    int perPage = 20,
  });
  Future<APIResponse> getNotificationDetails(String notificationId);
  Future<APIResponse> markNotificationAsClicked(String notificationId);
  Future<APIResponse> getNotificationStatistics({
    String? deviceId,
    String? fromDate,
    String? toDate,
    String? groupBy,
  });
  
  // Testing
  Future<APIResponse> sendTestNotification(String deviceId, {String? title, String? body});
  Future<APIResponse> validateFCMToken(String deviceId);
}
```

### 3. Controller Layer

#### 3.1 NotificationController (GetX)

Main controller for notification state management.

```dart
class NotificationController extends GetxController {
  final NotificationRepository _repository;
  
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
  
  // Initialization
  Future<void> _initializeNotifications();
  
  // Device Management
  Future<void> registerCurrentDevice();
  Future<void> loadDevices();
  Future<void> updateDeviceSettings(String deviceId, DeviceSettingsRequest request);
  Future<void> removeDevice(String deviceId);
  Future<void> setPrimaryDevice(String deviceId);
  
  // Notification Preferences
  Future<void> loadNotificationPreferences(String deviceId);
  Future<void> updateNotificationPreference(String deviceId, String notificationType, bool enabled);
  Future<void> toggleSound(String deviceId, String notificationType, bool enabled);
  Future<void> toggleVibration(String deviceId, String notificationType, bool enabled);
  Future<void> setQuietHours(String deviceId, bool enabled, String? start, String? end);
  
  // Notification History
  Future<void> loadNotificationHistory({Map<String, dynamic>? filters});
  Future<void> markNotificationAsClicked(String notificationId);
  
  // Statistics
  Future<void> loadStatistics({String? deviceId, String? fromDate, String? toDate});
  
  // Notification Handling
  void handleForegroundNotification(RemoteMessage message);
  void handleNotificationTap(RemoteMessage message);
  
  // Testing
  Future<void> sendTestNotification();
}
```

### 4. Data Models

#### 4.1 Device Model

```dart
class Device {
  final int id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? deviceModel;
  final String? deviceOsVersion;
  final String? appVersion;
  final bool isActive;
  final bool isPrimary;
  final bool notificationsEnabled;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  Device({...});
  
  factory Device.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### 4.2 NotificationPreferences Model

```dart
class NotificationPreferences {
  final GlobalPreferences global;
  final QuietHours? quietHours;
  final List<NotificationTypePreference> notificationTypes;
  
  NotificationPreferences({...});
  
  factory NotificationPreferences.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class GlobalPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  
  GlobalPreferences({...});
}

class QuietHours {
  final bool enabled;
  final String start;
  final String end;
  
  QuietHours({...});
}

class NotificationTypePreference {
  final String type;
  final bool enabled;
  final bool soundEnabled;
  final bool vibrationEnabled;
  
  NotificationTypePreference({...});
}
```

#### 4.3 NotificationHistoryItem Model

```dart
class NotificationHistoryItem {
  final int id;
  final String notificationType;
  final String title;
  final String body;
  final String status;
  final DateTime sentAt;
  final DateTime? deliveredAt;
  final DateTime? clickedAt;
  final Map<String, dynamic>? data;
  final DeviceInfo? device;
  
  NotificationHistoryItem({...});
  
  factory NotificationHistoryItem.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}
```

#### 4.4 NotificationStatistics Model

```dart
class NotificationStatistics {
  final OverallStats overall;
  final List<TypeStats> byType;
  final List<DeviceStats> byDevice;
  
  NotificationStatistics({...});
  
  factory NotificationStatistics.fromJson(Map<String, dynamic> json);
}

class OverallStats {
  final int totalSent;
  final int totalDelivered;
  final int totalClicked;
  final int totalFailed;
  final double deliveryRate;
  final double clickRate;
  
  OverallStats({...});
}
```

### 5. Request Models

```dart
class DeviceRegistrationRequest {
  final String deviceId;
  final String? deviceName;
  final String deviceType;
  final String? deviceModel;
  final String? deviceOsVersion;
  final String? appVersion;
  final String fcmToken;
  
  DeviceRegistrationRequest({...});
  
  Map<String, dynamic> toJson();
}

class DeviceSettingsRequest {
  final String? deviceName;
  final bool? notificationsEnabled;
  final bool? soundEnabled;
  final bool? vibrationEnabled;
  
  DeviceSettingsRequest({...});
  
  Map<String, dynamic> toJson();
}

class NotificationPreferenceRequest {
  final String notificationType;
  final bool? enabled;
  final bool? soundEnabled;
  final bool? vibrationEnabled;
  
  NotificationPreferenceRequest({...});
  
  Map<String, dynamic> toJson();
}

class QuietHoursRequest {
  final bool enabled;
  final String? start;
  final String? end;
  
  QuietHoursRequest({...});
  
  Map<String, dynamic> toJson();
}
```

## Data Flow

### Device Registration Flow

```
1. App Launch
   ↓
2. Check Authentication
   ↓
3. If Authenticated:
   ├─> Get/Create Device ID (UUID)
   ├─> Get Device Info (name, type, model, OS)
   ├─> Get App Version
   ├─> Initialize FCM
   ├─> Get FCM Token
   ↓
4. Build Registration Request
   ↓
5. Call API: POST /api/v1/{role}/devices/register
   ↓
6. If Success:
   ├─> Save registration status locally
   ├─> Save device ID
   └─> Setup notification listeners
   ↓
7. If Failure:
   ├─> Retry with exponential backoff (1s, 2s, 4s)
   └─> Log error (don't block user)
```

### Notification Reception Flow

```
FCM Receives Notification
   ↓
Check App State
   ├─> Foreground
   │   ├─> Show in-app banner
   │   ├─> Save to local history
   │   └─> Trigger callback
   │
   ├─> Background
   │   ├─> Show system notification
   │   ├─> Save to local history
   │   └─> Wait for user tap
   │
   └─> Terminated
       ├─> Wake app
       ├─> Show system notification
       ├─> Save to local history
       └─> Wait for user tap
```

### Notification Tap Flow

```
User Taps Notification
   ↓
Extract notification data
   ↓
Mark as clicked (API call)
   ↓
Parse notification type
   ├─> appointment_reminder → Navigate to Appointment Details
   ├─> chat_message → Navigate to Chat Screen
   ├─> doctor_assigned → Navigate to Consultation Screen
   ├─> consultation_started → Navigate to Video Call Screen
   ├─> prescription_ready → Navigate to Prescription Screen
   └─> default → Navigate to Home Screen
```

## Error Handling

### Error Scenarios and Handling

| Scenario | Handling Strategy |
|----------|------------------|
| FCM token is null | Retry getting token after 2 seconds, max 3 attempts |
| Device registration fails | Retry with exponential backoff, don't block login |
| Token refresh fails | Queue update, retry on next app launch |
| Preference update fails | Show error, revert to previous state |
| API unreachable | Cache operations, sync when connection restored |
| Invalid FCM token | Request new token, re-register device |
| Permission denied | Show settings prompt, disable notifications |
| Notification parsing fails | Log error, show generic notification |
| Navigation data invalid | Navigate to home screen |

### Retry Logic

```dart
class RetryPolicy {
  static const int maxAttempts = 3;
  static const List<int> backoffDelays = [1000, 2000, 4000]; // milliseconds
  
  static Future<T?> executeWithRetry<T>(
    Future<T> Function() operation,
    {int maxAttempts = maxAttempts}
  ) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (attempt == maxAttempts - 1) {
          rethrow;
        }
        await Future.delayed(Duration(milliseconds: backoffDelays[attempt]));
      }
    }
    return null;
  }
}
```

## Testing Strategy

### Unit Tests

1. DeviceService
   - Test device ID generation and persistence
   - Test device info retrieval
   - Test registration status management

2. FCMService
   - Test token retrieval
   - Test permission handling
   - Test listener setup

3. NotificationRepository
   - Test API request building
   - Test response parsing
   - Test error handling

4. NotificationController
   - Test state management
   - Test notification handling
   - Test preference updates

### Integration Tests

1. Device Registration Flow
   - Test complete registration process
   - Test token refresh flow
   - Test multi-device scenarios

2. Notification Flow
   - Test foreground notification handling
   - Test background notification handling
   - Test notification tap navigation

3. Preference Management
   - Test preference updates
   - Test quiet hours
   - Test bulk updates

### Manual Testing Checklist

- [ ] Device registers successfully on first login
- [ ] Device re-registers on app launch
- [ ] FCM token refreshes automatically
- [ ] Foreground notifications display correctly
- [ ] Background notifications display correctly
- [ ] Notification tap navigates correctly
- [ ] Preferences update successfully
- [ ] Quiet hours work correctly
- [ ] Multi-device support works
- [ ] Test notification sends successfully
- [ ] Notification history displays correctly
- [ ] Statistics display correctly

## Security Considerations

1. **Token Storage**: FCM tokens stored in SharedPreferences (encrypted on iOS, EncryptedSharedPreferences on Android)
2. **API Authentication**: All API calls include Bearer token in Authorization header
3. **Device ID**: UUID generated locally, never exposed to other users
4. **Notification Data**: Sensitive data sent in data payload, not in notification body
5. **Permission Handling**: Request permissions at appropriate time, respect user choice

## Performance Considerations

1. **Non-blocking Registration**: Device registration doesn't block login flow
2. **Background Processing**: Notification processing happens in background isolate
3. **Caching**: Device info and preferences cached locally
4. **Batch Operations**: Bulk preference updates reduce API calls
5. **Lazy Loading**: Notification history loaded on demand with pagination

## Platform-Specific Considerations

### Android

- Use `firebase_messaging` plugin
- Handle notification channels for Android 8+
- Request POST_NOTIFICATIONS permission for Android 13+
- Use EncryptedSharedPreferences for token storage

### iOS

- Request notification permissions explicitly
- Handle provisional authorization
- Configure notification categories
- Use Keychain for token storage

## Integration Points

### Existing Systems

1. **AuthProvider**: Get current user role and auth token
2. **AROGYAMAPI**: Use existing API service for network calls
3. **Routing**: Integrate with existing GetX routing
4. **SharedPreferences**: Use for local storage

### New Dependencies

```yaml
dependencies:
  firebase_core: ^2.24.2
  firebase_messaging: ^14.7.9
  flutter_local_notifications: ^16.3.0
```

## Migration Strategy

Since this is a new feature, no migration is needed. However:

1. Existing users will be prompted for notification permissions on next app launch
2. Device registration will happen automatically after login
3. Default notification preferences will be enabled for all types
4. Users can customize preferences in settings

## Monitoring and Analytics

### Metrics to Track

1. Device registration success rate
2. FCM token refresh rate
3. Notification delivery rate
4. Notification click-through rate
5. Preference update frequency
6. Error rates by type

### Logging

```dart
class NotificationLogger {
  static void logDeviceRegistration(String deviceId, bool success);
  static void logTokenRefresh(String oldToken, String newToken);
  static void logNotificationReceived(String notificationType);
  static void logNotificationClicked(String notificationType);
  static void logError(String operation, dynamic error);
}
```

## Future Enhancements

1. **Rich Notifications**: Support images, actions, and custom layouts
2. **Notification Grouping**: Group related notifications
3. **Smart Notifications**: ML-based notification timing
4. **Notification Scheduling**: Schedule notifications locally
5. **Notification Templates**: Customizable notification templates
6. **A/B Testing**: Test different notification strategies
7. **Notification Badges**: Show unread count on app icon
8. **Notification Sounds**: Custom sounds per notification type
