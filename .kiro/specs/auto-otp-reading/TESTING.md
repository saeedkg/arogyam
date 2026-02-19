# Testing Guide for Auto OTP Reading

## Prerequisites
1. Run `flutter pub get` to install the `sms_autofill` package
2. Build and install the app on an Android device (emulator or physical)
3. Get the app signature by checking debug logs when the OTP screen opens

## Test Scenarios

### 1. Test on Android Device with Real SMS

**Steps:**
1. Open the app and navigate to the OTP screen
2. Send an SMS to the device with the format:
   ```
   Your ASKIT health verification code is 123456. Valid for 5 minutes. Do not share with anyone.
   ```
3. **Expected Result:**
   - OTP fields should auto-fill with "123456"
   - Keyboard should dismiss automatically
   - Green snackbar should appear: "OTP auto-filled from SMS"
   - Verify button should become enabled

### 2. Test Edge Cases

**Test 2.1: User Already Typing**
1. Navigate to OTP screen
2. Manually type 1-2 digits
3. Receive SMS with OTP
4. **Expected:** Auto-fill should NOT override user input

**Test 2.2: Incorrect SMS Format**
1. Navigate to OTP screen
2. Send SMS without the expected format (e.g., "Your code is 123456")
3. **Expected:** OTP should NOT auto-fill, manual entry still works

**Test 2.3: Non-Numeric OTP**
1. Navigate to OTP screen
2. Send SMS with non-numeric code
3. **Expected:** OTP should NOT auto-fill

**Test 2.4: Multiple SMS Received**
1. Navigate to OTP screen
2. Send multiple OTP SMS messages quickly
3. **Expected:** First valid OTP should auto-fill, subsequent ones ignored

**Test 2.5: App in Background**
1. Navigate to OTP screen
2. Switch to another app
3. Receive OTP SMS
4. Return to the app
5. **Expected:** OTP should be auto-filled when returning

### 3. Test on iOS Device

**Steps:**
1. Build and install on iOS device
2. Navigate to OTP screen
3. Receive OTP SMS
4. **Expected:**
   - App should not crash
   - Manual entry should work normally
   - iOS system autofill may appear in keyboard suggestions (iOS 12+)

### 4. Test Error Scenarios

**Test 4.1: SMS Listener Initialization Failure**
1. Check debug logs for any initialization errors
2. **Expected:** App continues to work with manual entry

**Test 4.2: Permission Denied (if applicable)**
1. If SMS permissions are requested, deny them
2. **Expected:** App continues with manual entry, no crashes

### 5. Verify Cleanup

**Steps:**
1. Navigate to OTP screen
2. Receive and auto-fill OTP
3. Navigate back or complete verification
4. **Expected:** SMS listener should stop (check logs for "cancel" call)

## Debug Information

### Getting App Signature
When you open the OTP screen, check the debug console for:
```
App Signature for SMS: <your-app-signature>
```

Share this signature with your backend team so they can include it in the SMS message for enhanced security (optional but recommended).

### SMS Format with App Signature (Optional)
```
<#> Your ASKIT health verification code is 123456. Valid for 5 minutes. Do not share with anyone.
<your-app-signature>
```

## Known Limitations

1. **iOS:** Limited SMS access due to platform restrictions. System-level autofill may work on iOS 12+
2. **Android < 8.0:** May require explicit SMS permissions
3. **Emulators:** SMS testing works but may require manual SMS sending via emulator controls

## Troubleshooting

### OTP Not Auto-Filling
1. Check debug logs for "OTP detected from SMS" message
2. Verify SMS format matches expected pattern
3. Ensure app signature is correct (if using enhanced security)
4. Check that user hasn't already started typing

### App Crashes
1. Check if `sms_autofill` package is properly installed
2. Verify `flutter pub get` was run
3. Check for any platform-specific issues in logs

### Permission Issues
1. SMS Retriever API (Android 8+) doesn't require permissions
2. For older Android, you may need to add SMS permissions to AndroidManifest.xml
