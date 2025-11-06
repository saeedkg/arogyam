# Consultation Module - Dyte Integration

This module handles video consultations using the Dyte SDK.

## Dyte SDK Integration

The integration follows the official Dyte Flutter UI Kit documentation:

### Step 1: Meeting Info Object
```dart
final meetingInfo = DyteMeetingInfoV2(authToken: '<auth_token>');
```

### Step 2: Build UIKit Info
```dart
final uikitInfo = DyteUIKitInfo(
  meetingInfo,
  designToken: DyteDesignTokens(
    colorToken: DyteColorToken(
      brandColor: Colors.blue,
      backgroundColor: Colors.black,
      textOnBackground: Colors.white,
      textOnBrand: Colors.white,
    ),
  ),
);
```

### Step 3: Build UIKit
```dart
final uiKit = DyteUIKitBuilder.build(uiKitInfo: uikitInfo);
```

### Step 4: Load UI
```dart
return uiKit.loadUI();
```

## Usage

### Navigate to Video Call
```dart
Get.to(() => VideoCallScreen(
  doctorName: 'Dr. Smith',
  specialization: 'Cardiologist',
  hospital: 'City Hospital',
  doctorImageUrl: 'https://...',
  authToken: '<dyte_auth_token>', // Required from backend
  roomName: 'room_123', // Optional
  participantId: 'patient_456', // Optional
));
```

## Files Structure

```
lib/consultation/
├── service/
│   └── dyte_service.dart       # Dyte SDK wrapper
├── ui/
│   └── video_call_screen.dart  # Video call UI
└── utils/
    └── permission_handler.dart # Camera/mic permissions
```

## Key Features

- ✅ Simplified Dyte SDK integration
- ✅ Auth token validation
- ✅ Custom branding colors
- ✅ Error handling
- ✅ Permission handling
- ✅ Clean UI with Dyte's prebuilt components

## Auth Token

The `authToken` must be obtained from your backend API. It should be a valid Dyte meeting token that includes:
- Organization ID
- Meeting ID
- Participant ID
- Preset ID
- Expiration time

Example flow:
1. User books appointment
2. Backend creates Dyte meeting and participant
3. Backend returns auth token
4. App uses auth token to join meeting

## Notes

- Auth token is required to join a meeting
- The DyteService provides a static method to build the meeting UI
- All Dyte UI customization is done through DyteDesignTokens
- The meeting UI is fully managed by Dyte's prebuilt components
