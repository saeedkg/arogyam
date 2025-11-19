# RealtimeKit SDK Integration - TODO

## Current Status

✅ **UI Implementation**: Complete and functional
✅ **Architecture**: Service → Controller → UI layers implemented
✅ **State Management**: GetX reactive state working
✅ **Navigation**: Integrated with PendingConsultationScreen
⚠️ **SDK Integration**: Placeholder implementation (needs actual SDK code)

## What's Working Now

The app will now run without crashing and show the video call UI with:
- ✅ Loading state while "connecting"
- ✅ Video call UI with controls
- ✅ Audio/video toggle buttons (UI only)
- ✅ End call button with confirmation
- ✅ Error handling and retry
- ✅ Navigation back to previous screen

## What Needs SDK Integration

The following methods in `lib/consultation/service/realtimekit_service.dart` have placeholder implementations marked with `// TODO`:

### 1. Initialize Meeting (Line ~48)
```dart
// TODO: Initialize RealtimeKit client with actual SDK
// Replace this:
_client = Object(); // Placeholder

// With actual SDK code:
final meetingInfo = RtkMeetingInfo(authToken: authToken);
_client = RtkClient();
await _client.init(meetingInfo);
```

### 2. Join Meeting (Line ~95)
```dart
// TODO: Call actual SDK join method
// Replace this:
_updateConnectionState(app.ConnectionState.connected);

// With actual SDK code:
await _client.joinRoom();
_updateConnectionState(app.ConnectionState.connected);
```

### 3. Leave Meeting (Line ~120)
```dart
// TODO: Call actual SDK leave method
// Replace this:
_updateConnectionState(app.ConnectionState.disconnected);

// With actual SDK code:
await _client.leaveRoom();
_updateConnectionState(app.ConnectionState.disconnected);
```

### 4. Toggle Audio (Line ~135)
```dart
// TODO: Call actual SDK audio toggle methods
// Replace this:
_isAudioEnabled = !_isAudioEnabled;

// With actual SDK code:
if (_isAudioEnabled) {
  await _client.localUser.disableAudio();
  _isAudioEnabled = false;
} else {
  await _client.localUser.enableAudio();
  _isAudioEnabled = true;
}
```

### 5. Toggle Video (Line ~155)
```dart
// TODO: Call actual SDK video toggle methods
// Replace this:
_isVideoEnabled = !_isVideoEnabled;

// With actual SDK code:
if (_isVideoEnabled) {
  await _client.localUser.disableVideo();
  _isVideoEnabled = false;
} else {
  await _client.localUser.enableVideo();
  _isVideoEnabled = true;
}
```

### 6. Video Renderers (Line ~175)
```dart
// TODO: Return actual video renderer from SDK
// Replace placeholders with:
return RtkVideoView(participant: _client.localUser);  // Local video
return RtkVideoView(participant: _client.participants.active.first);  // Remote video
```

### 7. Event Listeners (Line ~80)
```dart
// TODO: Add event listeners based on actual SDK API
// Example structure:
_client.addMeetingRoomEventsListener(
  onJoinCompleted: () => _updateConnectionState(app.ConnectionState.connected),
  onJoinFailed: (e) => _updateConnectionState(app.ConnectionState.failed),
  onDisconnected: () => _updateConnectionState(app.ConnectionState.disconnected),
  onParticipantJoin: (participant) => _handleParticipantJoined(participant),
  onParticipantLeave: (participant) => _handleParticipantLeft(participant),
);
```

## How to Integrate the Actual SDK

### Step 1: Check SDK Documentation
Look at the `realtimekit_core` package documentation to find:
- How to create a client instance
- How to initialize with auth token
- How to join/leave rooms
- How to control audio/video
- How to render video views
- Event listener APIs

### Step 2: Update Service Methods
Replace each `// TODO` section with actual SDK calls based on the documentation.

### Step 3: Update Video Rendering
In `lib/consultation/ui/realtimekit_video_call_screen.dart`:

**Remote Video (Line ~60):**
```dart
Widget _buildRemoteVideo() {
  // Replace the placeholder Container with:
  return controller._service?.getRemoteVideoRenderer() ?? Container(...);
}
```

**Local Video (Line ~95):**
```dart
Widget _buildLocalVideo() {
  return Obx(() {
    if (!controller.isVideoEnabled.value) {
      return Container(...); // Placeholder when disabled
    }
    // Replace with actual local video:
    return controller._service?.getLocalVideoRenderer() ?? Container(...);
  });
}
```

### Step 4: Test Integration
1. Join a consultation from PendingConsultationScreen
2. Verify video feeds appear
3. Test audio toggle
4. Test video toggle
5. Test end call
6. Test error scenarios

## Expected SDK API Pattern

Based on similar video SDKs, the API likely looks like:

```dart
// Initialize
final meetingInfo = RtkMeetingInfo(authToken: token);
final client = RtkClient();
await client.init(meetingInfo);

// Join
await client.joinRoom();

// Audio control
await client.localUser.enableAudio();
await client.localUser.disableAudio();

// Video control
await client.localUser.enableVideo();
await client.localUser.disableVideo();

// Video views
RtkVideoView(participant: client.localUser)  // Local
RtkVideoView(participant: client.participants.active.first)  // Remote

// Events
client.addMeetingRoomEventsListener(
  RtkMeetingRoomEventsListener(
    onMeetingRoomJoinCompleted: () {},
    onMeetingRoomJoinFailed: (e) {},
    onMeetingRoomDisconnected: () {},
    onParticipantJoin: (p) {},
    onParticipantLeave: (p) {},
  ),
);

// Leave
await client.leaveRoom();
```

## Testing Without SDK

The current placeholder implementation allows you to:
- ✅ Test the UI flow
- ✅ Test navigation
- ✅ Test error handling
- ✅ Test state management
- ✅ Verify button interactions
- ❌ No actual video (shows placeholders)
- ❌ No actual audio control
- ❌ No real connection

## Quick Reference

**Files to update when integrating SDK:**
1. `lib/consultation/service/realtimekit_service.dart` - Replace all TODO sections
2. `lib/consultation/ui/realtimekit_video_call_screen.dart` - Update video renderers

**Files that are complete:**
- ✅ `lib/consultation/controller/realtimekit_video_call_controller.dart`
- ✅ `lib/consultation/entities/*.dart`
- ✅ `lib/consultation_pending/ui/pending_consultation_screen.dart`
- ✅ `lib/_shared/routing/app_routes.dart`

## Summary

The video call feature is **architecturally complete** and **UI functional**. The only remaining work is replacing the placeholder SDK calls with actual `realtimekit_core` SDK methods once you have access to the SDK documentation or examples.

The app will run and show the video call UI, but won't have actual video/audio functionality until the SDK is integrated. This allows you to test the user experience and flow while waiting for SDK integration details.
