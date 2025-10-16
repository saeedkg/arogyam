# Dyte Video Call Integration Setup

This document explains how to set up Dyte video calling functionality in the Arogyam app.

## Prerequisites

1. **Dyte Account**: Sign up at [dyte.io](https://dyte.io)
2. **API Keys**: Get your API keys from the Dyte dashboard
3. **Backend Setup**: You'll need a backend to generate auth tokens and manage meetings

## Current Implementation

The app currently uses demo/placeholder tokens for development. For production, you need to:

### 1. Backend Integration

Replace the placeholder methods in `lib/consultation/service/dyte_service.dart`:

```dart
// Replace these methods with actual API calls to your backend
static String generateAuthToken({
  required String roomName,
  required String participantName,
  String? participantId,
}) {
  // Call your backend API to generate auth token
  // POST to your backend with room details
}

static String generateRoomName() {
  // Call your backend API to create a meeting room
  // POST to your backend to create room
}
```

### 2. Backend API Endpoints

You need to create these endpoints on your backend:

#### Create Meeting Room
```http
POST /api/meetings/create
Content-Type: application/json

{
  "title": "Doctor Consultation",
  "participantName": "Patient Name",
  "participantId": "patient_id_123"
}
```

Response:
```json
{
  "roomName": "meeting_room_123",
  "authToken": "dyte_auth_token_here",
  "meetingId": "meeting_id_123"
}
```

#### Generate Auth Token
```http
POST /api/meetings/auth-token
Content-Type: application/json

{
  "roomName": "meeting_room_123",
  "participantName": "Patient Name",
  "participantId": "patient_id_123",
  "role": "participant"
}
```

### 3. Environment Configuration

Create environment-specific configurations:

```dart
// lib/config/app_config.dart
class AppConfig {
  static const String dyteApiKey = String.fromEnvironment('DYTE_API_KEY');
  static const String dyteApiSecret = String.fromEnvironment('DYTE_API_SECRET');
  static const String backendBaseUrl = String.fromEnvironment('BACKEND_URL');
}
```

### 4. Production Setup

1. **Get Dyte API Keys**:
   - Go to [Dyte Dashboard](https://app.dyte.io)
   - Create a new project
   - Get your API key and secret

2. **Backend Implementation**:
   ```javascript
   // Node.js example
   const DyteAPI = require('@dytesdk/apis');
   
   const dyteAPI = new DyteAPI({
     apiKey: process.env.DYTE_API_KEY,
     apiSecret: process.env.DYTE_API_SECRET,
     baseUrl: 'https://api.dyte.io/v2',
   });
   
   // Create meeting
   app.post('/api/meetings/create', async (req, res) => {
     try {
       const meeting = await dyteAPI.meetings.create({
         title: req.body.title,
       });
       
       const authToken = await dyteAPI.meetings.createAuthToken(
         meeting.data.meeting.id,
         {
           name: req.body.participantName,
           presetName: 'participant',
           customParticipantId: req.body.participantId,
         }
       );
       
       res.json({
         roomName: meeting.data.meeting.roomName,
         authToken: authToken.data.token,
         meetingId: meeting.data.meeting.id,
       });
     } catch (error) {
       res.status(500).json({ error: error.message });
     }
   });
   ```

3. **Update Service**:
   ```dart
   // Update DyteService to use real API calls
   static Future<String> generateAuthToken({
     required String roomName,
     required String participantName,
     String? participantId,
   }) async {
     final response = await dio.post(
       '$backendBaseUrl/api/meetings/auth-token',
       data: {
         'roomName': roomName,
         'participantName': participantName,
         'participantId': participantId,
       },
     );
     
     return response.data['authToken'];
   }
   ```

## Features Implemented

### ✅ Completed
- [x] Dyte Flutter SDK integration
- [x] Video call screen UI
- [x] Camera and microphone controls
- [x] Permission handling
- [x] Navigation from consultation confirmation
- [x] Call controls (mute, video toggle, camera switch, screen share)
- [x] Error handling and loading states
- [x] Android and iOS permissions

### 🔄 Features Available
- **Video/Audio Calls**: Full video and audio calling capabilities
- **Screen Sharing**: Share screen with doctor
- **Camera Controls**: Switch between front/back camera
- **Audio Controls**: Mute/unmute microphone
- **Video Controls**: Turn video on/off
- **Call Management**: Join/leave meetings
- **Participant Management**: See who's in the call
- **Error Handling**: Connection errors and retry mechanisms

## Testing

### Development Testing
1. Run the app
2. Navigate to a doctor consultation
3. Tap "Join Instant Consultation"
4. Grant camera/microphone permissions
5. The demo will show the video call interface

### Production Testing
1. Set up your backend with Dyte API
2. Update the service methods to use real API calls
3. Test with actual meeting creation and auth token generation

## Troubleshooting

### Common Issues

1. **Permission Denied**:
   - Ensure permissions are properly requested
   - Check Android/iOS manifest files
   - Test on physical device (not simulator for camera)

2. **Connection Issues**:
   - Check internet connection
   - Verify auth token is valid
   - Ensure room exists and is active

3. **Video Not Working**:
   - Check camera permissions
   - Test on physical device
   - Verify Dyte client initialization

### Debug Mode
Enable debug logging in `DyteService`:
```dart
if (kDebugMode) {
  print('Dyte debug info: $debugInfo');
}
```

## Next Steps

1. **Backend Integration**: Implement real API endpoints
2. **User Management**: Integrate with your user system
3. **Call History**: Store call records
4. **Notifications**: Push notifications for incoming calls
5. **Recording**: Enable call recording (if needed)
6. **Analytics**: Track call quality and duration

## Resources

- [Dyte Flutter SDK Documentation](https://docs.dyte.io/flutter)
- [Dyte API Documentation](https://docs.dyte.io/api-reference)
- [Dyte Dashboard](https://app.dyte.io)
- [Flutter Permissions](https://pub.dev/packages/permission_handler)
