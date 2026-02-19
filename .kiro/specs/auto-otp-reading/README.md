# Auto OTP Reading Feature

## Overview
This feature enables automatic OTP reading and auto-filling in the EnterOtpScreen. When users receive an SMS containing their verification code from CP-ASKIT-T, the application automatically detects, extracts, and fills the OTP into the input fields.

## Implementation Details

### Package Used
- **sms_autofill**: ^2.4.0
  - Uses SMS Retriever API on Android 8.0+ (no permissions required)
  - Provides CodeAutoFill mixin for easy integration
  - Handles platform differences automatically

### Key Features
1. **Automatic SMS Detection**: Listens for incoming SMS messages on Android
2. **OTP Extraction**: Extracts 6-digit codes using regex pattern
3. **Auto-Fill**: Automatically populates OTP input fields
4. **User Input Protection**: Doesn't override if user has started typing
5. **Visual Feedback**: Shows confirmation snackbar when OTP is auto-filled
6. **Platform Support**: Works on Android 8.0+, graceful fallback on iOS

### SMS Message Format
The expected SMS format is:
```
Your ASKIT health verification code is [6-digit-code]. Valid for 5 minutes. Do not share with anyone.
```

Example:
```
Your ASKIT health verification code is 908726. Valid for 5 minutes. Do not share with anyone.
```

### Optional: Enhanced Security with App Signature
For enhanced security, you can include the app signature in the SMS message:
```
<#> Your ASKIT health verification code is 908726. Valid for 5 minutes. Do not share with anyone.
[APP_SIGNATURE]
```

To get your app signature:
1. Run the app and navigate to the OTP screen
2. Check debug logs for: `App Signature for SMS: <signature>`
3. Share this signature with your backend team

## Usage

### For Developers
The feature is automatically enabled when users navigate to the EnterOtpScreen. No additional configuration is needed.

### For Backend Team
Ensure SMS messages are sent with the correct format:
- Sender: CP-ASKIT-T
- Message format: "Your ASKIT health verification code is [CODE]. Valid for 5 minutes. Do not share with anyone."
- Optional: Include app signature for enhanced filtering

## Testing
See [TESTING.md](./TESTING.md) for detailed testing instructions and scenarios.

## Platform Behavior

### Android (8.0+)
- Uses SMS Retriever API
- No permissions required
- Automatic OTP detection and auto-fill
- Works in foreground and background

### Android (< 8.0)
- May require SMS permissions
- Add to AndroidManifest.xml if needed:
  ```xml
  <uses-permission android:name="android.permission.RECEIVE_SMS" />
  <uses-permission android:name="android.permission.READ_SMS" />
  ```

### iOS
- Limited SMS access due to platform restrictions
- System-level autofill may work on iOS 12+ (appears in keyboard suggestions)
- Manual entry always available as fallback

## Security & Privacy
- Only reads OTP messages (using SMS Retriever API)
- No SMS content is stored permanently
- Stops listening when screen is closed or verification completes
- Complies with platform security guidelines

## Troubleshooting

### OTP Not Auto-Filling
1. Verify SMS format matches expected pattern
2. Check debug logs for "OTP detected from SMS" message
3. Ensure user hasn't already started typing
4. Verify app signature if using enhanced security

### App Crashes
1. Ensure `flutter pub get` was run after adding the package
2. Check platform-specific logs for errors
3. Verify Android version compatibility

## Files Modified
- `lib/auth/enter_otp_screen.dart` - Added SMS autofill functionality
- `pubspec.yaml` - Added sms_autofill package
- `android/app/src/main/AndroidManifest.xml` - Added documentation comments

## Dependencies
- sms_autofill: ^2.4.0

## Future Enhancements
- Support for custom SMS formats
- Configurable OTP length
- Support for alphanumeric OTPs
- Enhanced error reporting
