# Implementation Plan

- [x] 1. Setup Firebase and dependencies



  - Add Firebase dependencies to pubspec.yaml (firebase_core, firebase_messaging, flutter_local_notifications)
  - Run `flutterfire configure` to generate firebase_options.dart
  - Initialize Firebase in main.dart
  - _Requirements: 1.1, 1.2_

- [x] 2. Implement DeviceService for device identification


  - Create lib/notification/service/device_service.dart
  - Implement getOrCreateDeviceId() to generate/retrieve UUID
  - Implement getDeviceInfo() to collect device details (name, type, model, OS version)
  - Implement registration status management (isDeviceRegistered, markDeviceRegistered, clearRegistrationStatus)
  - Implement FCM token storage methods (getStoredFCMToken, saveFCMToken)
  - _Requirements: 1.1, 1.2, 1.3_

- [x] 3. Implement FCMService for Firebase messaging


  - Create lib/notification/service/fcm_service.dart
  - Implement initialize() to setup FCM and request permissions
  - Implement getToken() to retrieve FCM token
  - Implement setupTokenRefreshListener() for automatic token updates
  - Implement setupForegroundMessageHandler() for foreground notifications
  - Implement setupBackgroundMessageHandler() for background notifications
  - Implement setupNotificationTapHandler() for notification tap events
  - Implement permission management methods (requestPermission, getPermissionStatus)
  - _Requirements: 1.1, 1.4, 4.1, 4.2, 4.3, 9.1, 9.2, 9.3, 9.4_

- [x] 4. Implement NotificationService for local notification handling


  - Create lib/notification/service/notification_service.dart
  - Implement initialize() to setup flutter_local_notifications
  - Implement showForegroundNotification() to display in-app notifications
  - Implement handleNotificationTap() to process notification taps
  - Implement saveNotificationToHistory() for local storage
  - Implement getLocalHistory() to retrieve notification history
  - Implement clearHistory() and markAsRead() methods
  - _Requirements: 4.1, 4.2, 4.3, 5.1, 5.2, 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 5. Create notification data models


  - Create lib/notification/entities/device.dart with Device model
  - Create lib/notification/entities/notification_preferences.dart with NotificationPreferences, GlobalPreferences, QuietHours, NotificationTypePreference models
  - Create lib/notification/entities/notification_history_item.dart with NotificationHistoryItem model
  - Create lib/notification/entities/notification_statistics.dart with NotificationStatistics, OverallStats, TypeStats, DeviceStats models
  - Create lib/notification/entities/requests/ folder with DeviceRegistrationRequest, DeviceSettingsRequest, NotificationPreferenceRequest, QuietHoursRequest models
  - Implement fromJson() and toJson() methods for all models
  - _Requirements: 1.1, 2.1, 3.1, 5.1, 6.1_

- [x] 6. Implement NotificationRepository for API communication



  - Create lib/notification/repository/notification_repository.dart
  - Inject AROGYAMAPI instance for network calls
  - Implement device management methods (registerDevice, getDevices, getDeviceDetails, updateDeviceSettings, removeDevice, setPrimaryDevice, refreshFCMToken)
  - Implement notification preference methods (getNotificationPreferences, updateNotificationPreference, setQuietHours, bulkUpdatePreferences)
  - Implement notification history methods (getNotificationHistory, getNotificationDetails, markNotificationAsClicked, getNotificationStatistics)
  - Implement testing methods (sendTestNotification, validateFCMToken)
  - Add proper error handling and response parsing
  - _Requirements: 1.1, 1.2, 1.3, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 5.1, 5.2, 5.3, 6.1, 12.1, 12.2, 12.3_

- [x] 7. Implement NotificationController with GetX


  - Create lib/notification/controller/notification_controller.dart
  - Define observable state variables (devices, notificationHistory, preferences, statistics, isLoading, currentDeviceId)
  - Implement onInit() to initialize notifications
  - Implement device management methods (registerCurrentDevice, loadDevices, updateDeviceSettings, removeDevice, setPrimaryDevice)
  - Implement notification preference methods (loadNotificationPreferences, updateNotificationPreference, toggleSound, toggleVibration, setQuietHours)
  - Implement notification history methods (loadNotificationHistory, markNotificationAsClicked)
  - Implement statistics methods (loadStatistics)
  - Implement notification handling methods (handleForegroundNotification, handleNotificationTap)
  - Implement sendTestNotification() for testing
  - _Requirements: 1.1, 2.1, 2.2, 2.3, 3.1, 3.2, 3.3, 4.4, 5.1, 5.2, 6.1, 12.1_

- [x] 8. Integrate FCM initialization in main.dart


  - Import Firebase and FCM services
  - Initialize Firebase before runApp()
  - Initialize FCMService and request permissions
  - Setup token refresh listener to update backend
  - Setup foreground message handler
  - Setup background message handler
  - Setup notification tap handler with navigation logic
  - _Requirements: 1.1, 1.4, 4.1, 4.2, 4.3, 4.4, 8.1, 8.2, 8.3_

- [x] 9. Implement device registration on login


  - Modify auth flow to trigger device registration after successful login
  - Call NotificationController.registerCurrentDevice() after auth token is saved
  - Implement non-blocking registration (don't wait for completion)
  - Add retry logic with exponential backoff for failed registrations
  - Store user role (patient/doctor) for role-based API endpoints
  - _Requirements: 1.1, 1.2, 1.3, 1.5, 10.1, 10.2, 11.1, 11.2_

- [x] 10. Implement device re-registration on app launch


  - Add device re-registration logic in app initialization
  - Check if user is authenticated
  - If authenticated, call registerCurrentDevice() to update last_used_at
  - Handle registration silently in background
  - _Requirements: 1.1, 1.3_

- [x] 11. Implement notification routing and navigation


  - Create lib/notification/utils/notification_router.dart
  - Implement routing logic for each notification type (appointment_reminder, chat_message, doctor_assigned, consultation_started, prescription_ready, etc.)
  - Map notification types to screen routes
  - Extract notification data and pass to destination screens
  - Handle invalid navigation data gracefully (fallback to home)
  - _Requirements: 4.4, 4.5, 4.6, 8.4, 8.5, 11.3, 11.4_

- [x] 12. Implement error handling and retry logic



  - Create lib/notification/utils/retry_policy.dart with RetryPolicy class
  - Implement executeWithRetry() method with exponential backoff
  - Add error handling in NotificationRepository for API failures
  - Implement token validation and refresh on invalid token errors
  - Add offline queue for failed operations
  - Implement sync mechanism when connection is restored
  - _Requirements: 1.5, 10.1, 10.2, 10.3, 10.4, 10.5_

- [x] 13. Implement notification permission handling


  - Add permission check on first login
  - Show permission rationale before requesting
  - Handle permission denial gracefully
  - Add settings prompt for denied permissions
  - Update device registration status based on permission
  - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5_

- [x] 14. Implement role-based notification support


  - Add role detection from AuthProvider
  - Use role-specific API endpoints (/api/v1/patient/devices or /api/v1/doctor/devices)
  - Filter notification types based on user role
  - Handle role switching (re-register device with new role)
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5_

- [x] 15. Add notification logging and debugging


  - Create lib/notification/utils/notification_logger.dart
  - Implement logging for device registration events
  - Implement logging for token refresh events
  - Implement logging for notification received/clicked events
  - Implement error logging with detailed context
  - Add debug mode flag for verbose logging
  - _Requirements: 12.4, 12.5_

- [x] 16. Implement notification history tracking

  - Add local storage for notification history using SharedPreferences or Hive
  - Save notification metadata when received
  - Track delivery and click timestamps
  - Implement pagination for history list
  - Add filtering by type, date range, and status
  - Sync local history with backend periodically
  - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

- [x] 17. Implement notification statistics

  - Fetch statistics from backend API
  - Display overall stats (sent, delivered, clicked, failed, rates)
  - Group statistics by notification type
  - Group statistics by device
  - Add date range filtering
  - Cache statistics locally for offline access
  - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

- [x] 18. Add platform-specific configurations



  - Configure Android notification channels in AndroidManifest.xml
  - Add POST_NOTIFICATIONS permission for Android 13+
  - Configure iOS notification capabilities in Xcode
  - Setup iOS notification categories
  - Configure notification icons and sounds
  - _Requirements: 1.1, 4.1, 4.2_

- [x] 19. Implement foreground notification banner UI


  - Create lib/notification/ui/widgets/foreground_notification_banner.dart
  - Design in-app notification banner with title, body, and icon
  - Add auto-dismiss after 5 seconds
  - Add swipe-to-dismiss gesture
  - Add tap handler for navigation
  - Implement notification queue for multiple notifications
  - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5_

- [x] 20. Create notification history screen


  - Create lib/notification/ui/notification_history_screen.dart
  - Display paginated list of notifications with pull-to-refresh
  - Show notification details (title, body, timestamp, status, icon)
  - Add filtering options (type, date range, status) with filter chips
  - Add tap handler to navigate to relevant screen based on notification type
  - Show empty state when no notifications with illustration
  - Add loading state with shimmer effect
  - Integrate with NotificationController
  - _Requirements: 5.1, 5.2, 5.5_

- [x] 21. Integrate with existing app routing


  - Add notification-related routes to AppRoutes
  - Register NotificationController with GetX dependency injection
  - Add navigation from settings/profile to notification history screen
  - Add deep linking support for notification navigation
  - _Requirements: 4.4, 4.5, 4.6_

- [ ] 22. Handle logout and cleanup



  - Implement device deactivation on logout
  - Clear local notification data
  - Unregister FCM listeners
  - Clear cached preferences and history
  - _Requirements: 1.6_

- [x] 23. Add comprehensive error messages

  - Create user-friendly error messages for common failures
  - Add error dialogs for critical failures
  - Add retry buttons for failed operations
  - Show connection status indicators
  - _Requirements: 10.1, 10.2, 10.3, 10.4_

- [x] 24. Implement notification caching for offline support

  - Cache notification preferences locally
  - Queue failed API operations
  - Sync queued operations when online
  - Show offline indicator in UI
  - _Requirements: 10.4_

- [x] 25. Add notification analytics tracking

  - Track device registration success/failure
  - Track notification delivery rates
  - Track notification click-through rates
  - Track preference update frequency
  - Send analytics to backend
  - _Requirements: 5.3, 6.1, 6.2_

- [x] 26. Perform end-to-end testing


  - Test device registration flow on first login
  - Test device re-registration on app launch
  - Test FCM token refresh
  - Test foreground notification display
  - Test background notification display
  - Test notification tap navigation for all types
  - Test notification preferences update
  - Test quiet hours functionality
  - Test multi-device scenarios
  - Test offline/online transitions
  - Test permission handling
  - Test role-based notifications
  - Test error scenarios and retry logic
  - _Requirements: All_
