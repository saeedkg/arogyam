# Token Invalid Force Logout Implementation

## Overview
Implemented handling for `TOKEN_INVALID` error with `action: login` response from the dashboard API. When this error occurs, the app shows an alert dialog and forces the user to logout and login again.

## API Response Format
```json
{
  "success": false,
  "message": "Invalid token",
  "error_code": "TOKEN_INVALID",
  "action": "login"
}
```

## Implementation Details

### 1. Created TokenInvalidException
**File:** `lib/network/exceptions/token_invalid_exception.dart`

New exception class specifically for invalid token scenarios:
```dart
class TokenInvalidException extends APIException {
  TokenInvalidException(String message)
      : super(
          message,
          'Token is invalid - user needs to login again',
        );
}
```

### 2. Updated API Exception Exports
**File:** `lib/network/exceptions/api_exception.dart`

Added export for the new exception:
```dart
export 'token_invalid_exception.dart';
```

### 3. Updated Dashboard Service
**File:** `lib/landing/service/dashboard_service.dart`

Added specific handling for TOKEN_INVALID error in the dashboard API call:
```dart
// Check for TOKEN_INVALID with action: login
if (exception.responseData != null && exception.responseData is Map<String, dynamic>) {
  final responseMap = exception.responseData as Map<String, dynamic>;
  final errorCode = responseMap['error_code'];
  final action = responseMap['action'];
  
  // If token is invalid and action is login, throw special exception
  if (errorCode == 'TOKEN_INVALID' && action == 'login') {
    throw TokenInvalidException(responseMap['message'] ?? 'Your session has expired. Please login again.');
  }
}
```

### 4. Updated HomeController
**File:** `lib/landing/controller/home_controller.dart`

Added imports:
```dart
import 'package:flutter/material.dart';
import '../../auth/service/logout_service.dart';
import '../../_shared/routing/app_navigation.dart';
import '../../network/exceptions/token_invalid_exception.dart';
import '../../notification/service/fcm_service.dart';
import '../../notification/service/device_service.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/controller/notification_controller.dart';
```

Added exception handling in both `loadAll()` and `refreshDashboardData()`:
```dart
catch (e) {
  // Handle TOKEN_INVALID exception
  if (e is TokenInvalidException) {
    await _handleTokenInvalid(e.userReadableMessage);
    return;
  }
  // ... other error handling
}
```

Added new method to handle token invalid scenario:
```dart
/// Handle TOKEN_INVALID exception - show alert and force logout
Future<void> _handleTokenInvalid(String message) async {
  // Show alert dialog
  await Get.dialog(
    AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Session Expired',
        style: TextStyle(fontWeight: FontWeight.w700),
      ),
      content: Text(message),
      actions: [
        ElevatedButton(
          onPressed: () async {
            Get.back(); // Close dialog
            
            // Perform logout cleanup
            try {
              // Clear FCM token
              await FCMService.deleteToken();
              
              // Clear notification data
              await DeviceService.clearRegistrationStatus();
              await NotificationService.clearHistory();
              
              // Delete NotificationController
              if (Get.isRegistered<NotificationController>()) {
                Get.delete<NotificationController>();
              }
              
              // Clear all local user data
              await LogoutService().clearAllUserData();
            } catch (e) {
              // Continue to navigation even if cleanup fails
            }
            
            // Navigate to login screen
            AppNavigation.offAllToRequestOtpScreen();
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text('Login Again'),
        ),
      ],
    ),
    barrierDismissible: false,
  );
}
```

## User Flow

1. User opens the app and dashboard loads
2. API returns `{error_code: "TOKEN_INVALID", action: "login"}`
3. Dashboard service throws `TokenInvalidException`
4. HomeController catches the exception
5. Alert dialog appears with title "Session Expired" and the error message
6. User clicks "Login Again" button
7. App performs logout cleanup:
   - Clears FCM token
   - Clears device registration status
   - Clears notification history
   - Deletes NotificationController
   - Clears all local user data (via LogoutService)
8. User is redirected to RequestOtpScreen (login screen)

## Key Features

- **Non-dismissible Dialog**: User must click "Login Again" (barrierDismissible: false)
- **Automatic Cleanup**: Performs complete logout cleanup without requiring AuthProvider
- **Graceful Fallback**: If cleanup fails, user is still redirected to login screen
- **Specific to Dashboard API**: Only applies to the `/patient/dashboard` endpoint as requested
- **Clear User Communication**: Shows the exact error message from the API
- **No Dependencies on AuthProvider**: Works independently without requiring GetX-registered AuthProvider

## Technical Notes

- Uses `LogoutService().clearAllUserData()` directly instead of `AuthProvider.logout()`
- Uses `AppNavigation.offAllToRequestOtpScreen()` for navigation (existing app pattern)
- Performs all necessary cleanup steps that would normally be done in AuthProvider.logout()
- Handles errors gracefully - continues to login screen even if cleanup fails

## Testing Recommendations

1. Test with a valid token - should work normally
2. Test with TOKEN_EXPIRED (action: refresh) - should auto-refresh token
3. Test with TOKEN_INVALID (action: login) - should show alert and force logout
4. Test logout flow - ensure all data is cleared
5. Test re-login after forced logout - should work normally
6. Test error scenarios - ensure navigation works even if cleanup fails

## Related Files

- `lib/network/exceptions/token_invalid_exception.dart` (new)
- `lib/network/exceptions/api_exception.dart` (modified)
- `lib/landing/service/dashboard_service.dart` (modified)
- `lib/landing/controller/home_controller.dart` (modified)
- `lib/auth/service/logout_service.dart` (existing - used for cleanup)
- `lib/_shared/routing/app_navigation.dart` (existing - used for navigation)

