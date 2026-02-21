# Firebase Setup Instructions

## Prerequisites

You need to complete Firebase setup before the FCM notifications will work.

## Step 1: Install Firebase CLI

```bash
npm install -g firebase-tools
```

Or using curl:
```bash
curl -sL https://firebase.tools | bash
```

## Step 2: Install FlutterFire CLI

```bash
dart pub global activate flutterfire_cli
```

## Step 3: Login to Firebase

```bash
firebase login
```

## Step 4: Run FlutterFire Configure

From your project root directory, run:

```bash
flutterfire configure
```

This will:
1. Ask you to select your Firebase project (or create a new one)
2. Select platforms (Android and iOS)
3. Automatically generate `lib/firebase_options.dart` with your Firebase configuration
4. Update Android and iOS configuration files

## Step 5: Android Configuration

The `flutterfire configure` command should handle most of this, but verify:

### android/app/build.gradle.kts

Ensure you have:
```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services") // Add this line
}
```

### android/build.gradle.kts

Ensure you have:
```kotlin
buildscript {
    dependencies {
        classpath("com.google.gms:google-services:4.4.0") // Add this line
    }
}
```

### android/app/src/main/AndroidManifest.xml

Add inside `<application>` tag:
```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="high_importance_channel" />
```

Add permission before `<application>` tag:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
```

## Step 6: iOS Configuration

The `flutterfire configure` command should handle most of this, but verify:

### ios/Runner/Info.plist

Add before `</dict>`:
```xml
<key>FirebaseAppDelegateProxyEnabled</key>
<false/>
```

### Enable Push Notifications in Xcode

1. Open `ios/Runner.xcworkspace` in Xcode
2. Select Runner target
3. Go to "Signing & Capabilities"
4. Click "+ Capability"
5. Add "Push Notifications"
6. Add "Background Modes"
7. Check "Remote notifications" under Background Modes

## Step 7: Test Firebase Connection

After running `flutterfire configure`, your `lib/firebase_options.dart` will be updated with real values.

Run the app to verify Firebase initializes correctly.

## Troubleshooting

### Error: "No Firebase project found"
- Make sure you've created a Firebase project at https://console.firebase.google.com
- Run `firebase login` to authenticate

### Error: "FlutterFire CLI not found"
- Make sure you've activated it: `dart pub global activate flutterfire_cli`
- Add Dart global bin to PATH

### Android build errors
- Make sure you have `google-services.json` in `android/app/`
- Clean and rebuild: `flutter clean && flutter pub get`

### iOS build errors
- Make sure you have `GoogleService-Info.plist` in `ios/Runner/`
- Run `pod install` in the `ios` directory
- Clean and rebuild

## Next Steps

Once Firebase is configured, the FCM implementation will work automatically. The app will:
1. Request notification permissions
2. Get FCM token
3. Register device with backend
4. Receive push notifications
