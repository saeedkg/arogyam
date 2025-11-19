# Design Document: RealtimeKit Video Call Integration

## Overview

This design document outlines the implementation of a custom video call UI for doctor-patient consultations using the `realtimekit_core: ^0.1.3` library. The solution replaces the placeholder Dyte integration with a fully functional RealtimeKit-based video consultation system that provides custom UI controls and seamless integration with the existing consultation flow.

## Architecture

### High-Level Architecture

```
PendingConsultationScreen
    ↓ (Join Button Tap)
    ↓ (Pass: authToken, roomName, participantId, doctor info)
RealtimeKitVideoCallScreen
    ↓
RealtimeKitController (GetX)
    ↓
RealtimeKitService
    ↓
realtimekit_core SDK
```

### Component Layers

1. **UI Layer**: `RealtimeKitVideoCallScreen` - Custom Flutter UI with video feeds and controls
2. **Controller Layer**: `RealtimeKitVideoCallController` - State management using GetX
3. **Service Layer**: `RealtimeKitService` - Wrapper around realtimekit_core SDK
4. **SDK Layer**: `realtimekit_core` - Third-party video call library

## Components and Interfaces

### 1. RealtimeKitService

**Purpose**: Encapsulate all RealtimeKit SDK interactions and provide a clean API for the controller.

**Key Responsibilities**:
- Initialize RealtimeKit meeting
- Manage connection lifecycle
- Handle media streams (audio/video)
- Provide event callbacks for connection state changes
- Clean up resources on disposal

**Interface**:

```dart
class RealtimeKitService {
  // Initialize meeting with auth token
  Future<void> initializeMeeting({
    required String authToken,
    required String roomName,
    required String participantId,
  });
  
  // Join the meeting
  Future<void> joinMeeting();
  
  // Leave the meeting
  Future<void> leaveMeeting();
  
  // Toggle audio
  Future<void> toggleAudio();
  
  // Toggle video
  Future<void> toggleVideo();
  
  // Get current audio state
  bool get isAudioEnabled;
  
  // Get current video state
  bool get isVideoEnabled;
  
  // Get connection state
  ConnectionState get connectionState;
  
  // Stream of connection state changes
  Stream<ConnectionState> get connectionStateStream;
  
  // Stream of participant events
  Stream<ParticipantEvent> get participantEventStream;
  
  // Dispose resources
  void dispose();
}
```

### 2. RealtimeKitVideoCallController

**Purpose**: Manage video call state and coordinate between UI and service layer.

**Key Responsibilities**:
- Initialize and manage RealtimeKitService
- Handle UI state (loading, error, connected)
- Manage audio/video toggle states
- Handle call end confirmation
- Provide reactive state to UI using GetX

**State Properties**:

```dart
class RealtimeKitVideoCallController extends GetxController {
  // Observable states
  final isLoading = true.obs;
  final isConnected = false.obs;
  final isAudioEnabled = true.obs;
  final isVideoEnabled = true.obs;
  final error = Rxn<String>();
  final connectionState = Rx<ConnectionState>(ConnectionState.disconnected);
  
  // Doctor information
  late String doctorName;
  late String specialization;
  late String doctorImageUrl;
  
  // Meeting credentials
  late String authToken;
  late String roomName;
  late String participantId;
  
  // Service instance
  late RealtimeKitService _service;
  
  // Methods
  Future<void> initialize();
  Future<void> toggleAudio();
  Future<void> toggleVideo();
  Future<void> endCall();
  void handleError(String error);
}
```

### 3. RealtimeKitVideoCallScreen

**Purpose**: Provide custom video call UI with controls.

**UI Components**:

1. **Video Container** (Full Screen)
   - Remote video feed (doctor) - Full screen background
   - Local video feed (patient) - PiP overlay (top-right corner)
   - Connection status indicator

2. **Top Bar** (Overlay)
   - Doctor name and specialization
   - Call duration timer
   - Network quality indicator

3. **Bottom Control Bar** (Overlay)
   - Microphone toggle button (mute/unmute)
   - Camera toggle button (enable/disable)
   - End call button (red, prominent)

4. **Loading State**
   - Connecting indicator with doctor info
   - Progress indicator

5. **Error State**
   - Error message display
   - Retry button
   - Go back button

**Layout Structure**:

```
┌─────────────────────────────────────┐
│  Top Bar (Doctor Info, Timer)       │
├─────────────────────────────────────┤
│                                     │
│     Remote Video (Doctor)           │
│     [Full Screen Background]        │
│                                     │
│                    ┌──────────┐    │
│                    │  Local   │    │
│                    │  Video   │    │
│                    │  (PiP)   │    │
│                    └──────────┘    │
│                                     │
├─────────────────────────────────────┤
│  Bottom Controls                    │
│  [Mic] [Camera] [End Call]         │
└─────────────────────────────────────┘
```

## Data Models

### ConnectionState Enum

```dart
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  failed,
}
```

### ParticipantEvent

```dart
class ParticipantEvent {
  final String participantId;
  final ParticipantEventType type;
  final DateTime timestamp;
  
  ParticipantEvent({
    required this.participantId,
    required this.type,
    required this.timestamp,
  });
}

enum ParticipantEventType {
  joined,
  left,
  audioEnabled,
  audioDisabled,
  videoEnabled,
  videoDisabled,
}
```

### VideoCallConfig

```dart
class VideoCallConfig {
  final String authToken;
  final String roomName;
  final String participantId;
  final String doctorName;
  final String specialization;
  final String doctorImageUrl;
  
  VideoCallConfig({
    required this.authToken,
    required this.roomName,
    required this.participantId,
    required this.doctorName,
    required this.specialization,
    required this.doctorImageUrl,
  });
}
```

## Error Handling

### Error Categories

1. **Authentication Errors**
   - Invalid or missing auth token
   - Expired token
   - Unauthorized access

2. **Connection Errors**
   - Network unavailable
   - Connection timeout
   - Server unreachable

3. **Permission Errors**
   - Camera permission denied
   - Microphone permission denied

4. **Runtime Errors**
   - SDK initialization failure
   - Media device errors
   - Unexpected disconnection

### Error Handling Strategy

```dart
class VideoCallError {
  final VideoCallErrorType type;
  final String message;
  final String? technicalDetails;
  final bool isRecoverable;
  
  VideoCallError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.isRecoverable = false,
  });
  
  String getUserMessage() {
    switch (type) {
      case VideoCallErrorType.authentication:
        return 'Unable to authenticate. Please try again.';
      case VideoCallErrorType.connection:
        return 'Connection failed. Please check your internet.';
      case VideoCallErrorType.permission:
        return 'Camera or microphone permission required.';
      case VideoCallErrorType.runtime:
        return 'An unexpected error occurred.';
    }
  }
}

enum VideoCallErrorType {
  authentication,
  connection,
  permission,
  runtime,
}
```

## Testing Strategy

### Unit Tests

1. **RealtimeKitService Tests**
   - Test initialization with valid credentials
   - Test initialization with invalid credentials
   - Test audio toggle functionality
   - Test video toggle functionality
   - Test connection state transitions
   - Test resource cleanup on dispose

2. **RealtimeKitVideoCallController Tests**
   - Test controller initialization
   - Test state management (loading, connected, error)
   - Test audio/video toggle state updates
   - Test error handling
   - Test end call confirmation flow

### Integration Tests

1. **Video Call Flow Tests**
   - Test complete join flow from PendingConsultationScreen
   - Test successful connection and video display
   - Test audio/video controls during active call
   - Test end call flow and navigation back
   - Test error scenarios and recovery

### Widget Tests

1. **RealtimeKitVideoCallScreen Tests**
   - Test UI rendering in different states (loading, connected, error)
   - Test control button interactions
   - Test PiP video positioning
   - Test responsive layout

## Implementation Notes

### RealtimeKit SDK Integration

Based on the `realtimekit_core` library pattern (similar to Dyte), the integration will follow these steps:

1. **Initialize Meeting Info**
```dart
final meetingInfo = RtkMeetingInfo(
  authToken: authToken,
  roomName: roomName,
  participantId: participantId,
);
```

2. **Create Meeting Client**
```dart
final client = RealtimeKitClient();
await client.init(meetingInfo);
```

3. **Join Meeting**
```dart
await client.joinRoom();
```

4. **Access Media Controls**
```dart
// Toggle audio
await client.localUser.enableAudio();
await client.localUser.disableAudio();

// Toggle video
await client.localUser.enableVideo();
await client.localUser.disableVideo();
```

5. **Listen to Events**
```dart
client.addMeetingRoomEventsListener(MyMeetingListener());
```

6. **Render Video**
```dart
// Remote video
RealtimeKitVideoView(
  participant: client.participants.active.first,
);

// Local video
RealtimeKitVideoView(
  participant: client.localUser,
);
```

### Custom UI Implementation

The custom UI will be built using Flutter widgets with the following structure:

1. **Stack-based Layout**: Use Stack to overlay controls on video feeds
2. **Positioned Widgets**: Position PiP video and control bars
3. **Animated Transitions**: Smooth show/hide animations for controls
4. **Gesture Detection**: Tap to show/hide controls (optional enhancement)

### State Management Flow

```
User Action (Tap Mic Button)
    ↓
Controller.toggleAudio()
    ↓
Service.toggleAudio()
    ↓
RealtimeKit SDK
    ↓
Event Callback
    ↓
Controller Updates State
    ↓
UI Rebuilds (Obx)
```

### Resource Management

1. **On Screen Init**:
   - Request permissions
   - Initialize service
   - Connect to meeting

2. **During Call**:
   - Monitor connection state
   - Handle reconnection
   - Update UI state

3. **On Screen Dispose**:
   - Leave meeting
   - Release media resources
   - Dispose controller
   - Clean up listeners

### Navigation Flow

```
PendingConsultationScreen
    ↓ (Join Button)
    ↓ (Permission Check)
    ↓ (Confirmation Dialog)
    ↓
Get.to(() => RealtimeKitVideoCallScreen(...))
    ↓ (Call Active)
    ↓ (End Call Button)
    ↓ (Confirmation Dialog)
    ↓
Get.back() → PendingConsultationScreen
```

## Design Decisions and Rationales

### 1. Custom UI vs SDK UI

**Decision**: Build custom UI instead of using SDK's default UI.

**Rationale**:
- Full control over design and branding
- Consistent with app's design system
- Flexibility to add custom features
- Better user experience tailored to healthcare context

### 2. GetX for State Management

**Decision**: Use GetX for controller and state management.

**Rationale**:
- Already used throughout the app
- Reactive state updates with Obx
- Simple dependency injection
- Minimal boilerplate

### 3. Service Layer Abstraction

**Decision**: Create RealtimeKitService wrapper around SDK.

**Rationale**:
- Isolate SDK-specific code
- Easier to test
- Easier to swap SDK if needed
- Clean separation of concerns

### 4. Picture-in-Picture for Local Video

**Decision**: Show local video as small PiP overlay.

**Rationale**:
- Doctor's video is more important (patient wants to see doctor)
- Saves screen space
- Standard pattern in video call apps
- Patient can still verify their video is working

### 5. Minimal Controls

**Decision**: Only show essential controls (mic, camera, end call).

**Rationale**:
- Simplicity for healthcare users
- Reduce cognitive load during consultation
- Focus on the conversation
- Can add more features later if needed

## Security Considerations

1. **Token Handling**: Auth tokens should never be logged or exposed
2. **Secure Connection**: Ensure RealtimeKit uses encrypted connections
3. **Permission Management**: Request permissions only when needed
4. **Data Privacy**: No recording or storage of video/audio without consent

## Performance Considerations

1. **Video Quality**: Adaptive bitrate based on network conditions
2. **Resource Usage**: Monitor and optimize memory usage
3. **Battery Impact**: Minimize battery drain during long calls
4. **Network Efficiency**: Optimize bandwidth usage

## Accessibility Considerations

1. **Screen Reader Support**: Provide semantic labels for controls
2. **High Contrast**: Ensure controls are visible in all lighting
3. **Large Touch Targets**: Make buttons easy to tap
4. **Visual Feedback**: Clear indication of button states

## Future Enhancements

1. **Chat Feature**: Text chat during video call
2. **Screen Sharing**: Doctor can share medical images
3. **Recording**: Record consultation (with consent)
4. **Call Quality Metrics**: Display network quality and stats
5. **Virtual Background**: Blur or replace background
6. **Waiting Room**: Pre-call waiting area with connection test
