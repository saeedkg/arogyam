# How to Integrate RealtimeKit SDK - Step by Step

## Why is `_client` null?

The `_client` is null because we haven't integrated the actual RealtimeKit SDK yet. Even though you're getting an auth token from your API, we need to use that token with the RealtimeKit SDK to create a real video call client.

## Current Status

✅ **Your API gives you**: authToken, roomName, participantId
✅ **The app receives**: All the credentials correctly
❌ **What's missing**: Code to use those credentials with RealtimeKit SDK

## Step-by-Step Integration

### Step 1: Find the RealtimeKit SDK Documentation

You need to find out how to use the `realtimekit_core` package. Check:

1. **Package documentation**: https://pub.dev/packages/realtimekit_core
2. **GitHub repository**: Look for examples or README
3. **Example apps**: Check if there are sample projects

### Step 2: Understand the SDK API

You need to find out:
- How to create a client instance
- What parameters the initialization needs
- How to join a room
- How to control audio/video

### Step 3: Update the Service Code

Open `lib/consultation/service/realtimekit_service.dart` and replace the TODO sections.

#### Example Integration (adjust based on actual SDK):

```dart
import 'package:realtimekit_core/realtimekit_core.dart';

// In initializeMeeting():
final meetingInfo = RtkMeetingInfo(
  authToken: authToken,
  roomName: roomName,
  // Add other required parameters
);

_client = RtkClient();
await _client.init(meetingInfo);

// In joinMeeting():
await _client.joinRoom();

// In toggleAudio():
if (_isAudioEnabled) {
  await _client.localUser.disableAudio();
} else {
  await _client.localUser.enableAudio();
}

// In toggleVideo():
if (_isVideoEnabled) {
  await _client.localUser.disableVideo();
} else {
  await _client.localUser.enableVideo();
}
```

### Step 4: Check the Actual SDK Classes

Run this command to see what's available in the package:

```bash
flutter pub deps --style=tree | grep realtimekit
```

Or check the package files directly:
```bash
# On Windows
dir .dart_tool\pub\hosted\pub.dev\realtimekit_core-*\lib

# Look for main export file
type .dart_tool\pub\hosted\pub.dev\realtimekit_core-*\lib\realtimekit_core.dart
```

### Step 5: Test with Print Statements

Add logging to see what's happening:

```dart
print('Auth Token: ${authToken.substring(0, 20)}...');
print('Room Name: $roomName');
print('Participant ID: $participantId');
print('Client created: ${_client != null}');
```

### Step 6: Handle SDK Errors

Wrap SDK calls in try-catch:

```dart
try {
  _client = RtkClient();
  await _client.init(meetingInfo);
  print('✅ SDK initialized successfully');
} catch (e) {
  print('❌ SDK initialization failed: $e');
  throw VideoCallError.authentication(
    'Failed to initialize SDK',
    details: e.toString(),
  );
}
```

## Common SDK Patterns

Most video SDKs follow similar patterns:

### Pattern 1: Separate Meeting Info
```dart
final meetingInfo = RtkMeetingInfo(authToken: token);
final client = RtkClient();
await client.init(meetingInfo);
```

### Pattern 2: Direct Initialization
```dart
final client = RtkClient(authToken: token, roomName: room);
await client.connect();
```

### Pattern 3: Builder Pattern
```dart
final client = RtkClient.builder()
  .withAuthToken(token)
  .withRoomName(room)
  .build();
await client.initialize();
```

## Debugging Steps

### 1. Check if SDK is Imported
```dart
import 'package:realtimekit_core/realtimekit_core.dart';
```

### 2. Check Available Classes
Try typing `Rtk` in your IDE and see what autocomplete suggests.

### 3. Check SDK Examples
Look for example files in:
```
.dart_tool/pub/hosted/pub.dev/realtimekit_core-*/example/
```

### 4. Test Basic SDK Call
Try the simplest possible SDK call first:

```dart
try {
  print('Testing RealtimeKit SDK...');
  final client = RtkClient(); // Or whatever the class is called
  print('✅ SDK client created: ${client != null}');
} catch (e) {
  print('❌ SDK error: $e');
}
```

## What to Look For in SDK Documentation

1. **Initialization**:
   - What class creates the client?
   - What parameters does it need?
   - Is there an init() or connect() method?

2. **Authentication**:
   - How to pass the auth token?
   - Is room name needed during init?
   - Any other required parameters?

3. **Joining**:
   - Method to join a room/meeting
   - Is it async?
   - What does it return?

4. **Media Control**:
   - How to enable/disable audio?
   - How to enable/disable video?
   - Are there separate methods or one toggle method?

5. **Video Rendering**:
   - What widget renders video?
   - How to get local video view?
   - How to get remote video view?

6. **Events**:
   - How to listen for connection events?
   - How to listen for participant events?
   - What's the event listener API?

## Quick Test

To test if the SDK is working, add this to `initializeMeeting()`:

```dart
print('=== RealtimeKit SDK Test ===');
print('Auth Token: ${authToken.substring(0, 10)}...');
print('Room Name: $roomName');
print('Participant ID: $participantId');

try {
  // Try to import and use the SDK
  print('Attempting SDK initialization...');
  
  // Replace with actual SDK code:
  // final client = RtkClient();
  // print('Client created: ${client != null}');
  
  print('=== End Test ===');
} catch (e) {
  print('SDK Error: $e');
  print('Stack trace: ${StackTrace.current}');
}
```

## Need Help?

If you're stuck, share:
1. The RealtimeKit SDK documentation link
2. Any example code from the SDK
3. Error messages you're seeing
4. What classes/methods are available in the SDK

Then I can help you write the exact integration code!

## Summary

**The auth token is working fine** - your API is giving you the correct credentials. The problem is we haven't written the code to **use** those credentials with the RealtimeKit SDK yet. Once you find the SDK documentation or examples, we can integrate it properly.
