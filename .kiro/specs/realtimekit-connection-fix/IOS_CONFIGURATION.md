# iOS Configuration for RealtimeKit

## Critical Issue: Fake Plugin Override (For iOS Builds Only)

Your project currently has a **fake plugin override** for iOS development on Windows:

```yaml
# In pubspec.yaml
dependency_overrides:
  realtimekit_core_ios:
    path: fake_plugins/realtimekit_core_ios
```

### Why This Exists
This override allows development and testing on Windows, since the real iOS plugin can't be compiled on Windows.

### Important Notes
- **Keep this override for Windows/Android development** ✅
- **Remove only when building for iOS** (you'll handle this)
- This override does NOT affect Android functionality
- This override does NOT cause the Cloudflare dashboard issue

### The Real Issue
The Cloudflare dashboard problem is caused by **incomplete client disposal**, not the iOS plugin override. The fixes in this spec address the actual root cause.

## Solution

### For iOS Development/Testing
1. **Remove or comment out** the `dependency_overrides` section in `pubspec.yaml`
2. Run `flutter pub get`
3. Run `cd ios && pod install`
4. Build and test on iOS device or simulator

### For Windows Development
1. **Keep** the `dependency_overrides` section active
2. This allows the project to compile on Windows
3. Remember to remove it before iOS builds

### Recommended Approach
Use conditional configuration or build scripts:

```yaml
# pubspec.yaml
# Comment/uncomment based on target platform

# For Windows development:
dependency_overrides:
  realtimekit_core_ios:
    path: fake_plugins/realtimekit_core_ios

# For iOS builds: Comment out the above section
```

## iOS Requirements Checklist

### ✅ Already Configured Correctly

1. **Minimum iOS Version**: 15.0
   - Location: `ios/Podfile`
   - `platform :ios, '15.0'`

2. **Camera Permission**
   - Location: `ios/Runner/Info.plist`
   - Key: `NSCameraUsageDescription`
   - Value: "This app needs access to camera for video consultations with doctors."

3. **Microphone Permission**
   - Location: `ios/Runner/Info.plist`
   - Key: `NSMicrophoneUsageDescription`
   - Value: "This app needs access to microphone for audio consultations with doctors."

4. **Swift Version**: 5.0
   - Location: `ios/Podfile` (post_install)
   - `config.build_settings['SWIFT_VERSION'] = '5.0'`

5. **Frameworks**
   - Location: `ios/Podfile`
   - `use_frameworks!` ✅
   - `use_modular_headers!` ✅

### ⚠️ Optional: Background Audio Support

If you want audio to continue when the app is backgrounded during a call:

Add to `ios/Runner/Info.plist`:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
  <string>voip</string>
</array>
```

This is **optional** but recommended for better user experience.

## iOS Build Process

### First Time Setup
```bash
# 1. Remove fake plugin override from pubspec.yaml
# 2. Get dependencies
flutter pub get

# 3. Install iOS pods
cd ios
pod install
cd ..

# 4. Build for iOS
flutter build ios
# or
flutter run -d <ios-device-id>
```

### Troubleshooting iOS Build Issues

#### Issue: "Module 'realtimekit_core_ios' not found"
**Solution**: Make sure the fake plugin override is removed from pubspec.yaml

#### Issue: "No such module 'RealtimeKit'"
**Solution**: Run `cd ios && pod install` to install native dependencies

#### Issue: "Swift Compiler Error"
**Solution**: Verify Swift version is 5.0+ in Podfile post_install

#### Issue: Permissions not working
**Solution**: Check Info.plist has NSCameraUsageDescription and NSMicrophoneUsageDescription

## Testing on iOS

### Simulator Testing
```bash
# List available simulators
flutter devices

# Run on specific simulator
flutter run -d <simulator-id>
```

### Physical Device Testing
1. Connect iPhone via USB
2. Trust the computer on iPhone
3. Select device in Xcode or use `flutter devices`
4. Run: `flutter run -d <device-id>`

### What to Test on iOS
- [ ] App launches without crashes
- [ ] Camera permission is requested
- [ ] Microphone permission is requested
- [ ] Join consultation button works
- [ ] Video call connects (check RealtimeKit dashboard)
- [ ] Local video shows (your camera)
- [ ] Remote video shows (doctor's camera)
- [ ] Audio works (can hear and be heard)
- [ ] Mute/unmute works
- [ ] Camera on/off works
- [ ] End call works
- [ ] Can join second call without restart
- [ ] Background audio works (if implemented)

## RealtimeKit Documentation References

### Official Documentation
- **Package**: https://pub.dev/packages/realtimekit_core
- **API Docs**: https://pub.dev/documentation/realtimekit_core/latest/
- **Cloudflare Docs**: https://developers.cloudflare.com/calls/

### Key Documentation Pages
1. **Meeting Object**: https://developers.cloudflare.com/realtime/realtimekit/core/meeting-object-explained/
2. **iOS Setup**: Check package documentation for iOS-specific requirements
3. **Permissions**: Standard iOS camera/microphone permissions

## Version Information

- **Current Version**: 0.1.5+1 (resolved from ^0.1.3)
- **Recommended**: Update pubspec.yaml to `realtimekit_core: ^0.1.5`
- **Minimum iOS**: 13.0 (you're using 15.0 ✅)
- **Swift**: 5.0+ required

## Summary

**To make iOS work:**
1. ❌ Remove fake plugin override from pubspec.yaml
2. ✅ Verify permissions in Info.plist (already correct)
3. ✅ Verify Podfile configuration (already correct)
4. 🔄 Run `flutter pub get` and `cd ios && pod install`
5. 📱 Build and test on iOS device/simulator

**The main blocker is the fake plugin override.** Once removed, iOS should work correctly with your existing configuration.
