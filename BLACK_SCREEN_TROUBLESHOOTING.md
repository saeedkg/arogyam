# Black Screen Issue - Troubleshooting Guide

## Current Status
- ✅ Meeting connects successfully
- ✅ Audio works (can hear each other)
- ✅ Video codec is working (logs show 30fps encoding/decoding)
- ✅ Camera is active (permissions granted)
- ❌ Video views show black screens instead of video

## What the Logs Tell Us

### Good Signs
```
I/flutter: RealtimeKit: Successfully joined room
I/OplusFeedbackInfo: c2.mtk.vpx.decoder 640x480 inputFps=30 outputFps=30 renderFps=30
D/AudioRecord: start(2644): return status 0
```
- Meeting joined successfully
- Video codec is processing frames at 30fps
- Audio is working

### Potential Issues
```
E/flutter: FormatException: Invalid radix-16 number (at character 3)
E/flutter: FF 35F2B3
```
- Color parsing error in RealtimeKit SDK (design tokens)
- This might be affecting the video rendering

```
I/PlatformViewsController: Hosting view in view hierarchy for platform view: 3
I/PlatformViewsController: Hosting view in view hierarchy for platform view: 4
```
- Platform views are being created (good)
- But they might not be connected to video streams

## Possible Causes

### 1. VideoView Not Connected to Stream
The `VideoView` widget creates a platform view but might not be properly connected to the participant's video stream.

**Solution**: Ensure the participant object passed to `VideoView` has video enabled and is the correct participant.

### 2. Platform View Lifecycle Issue
The platform views might be created before the video stream is ready.

**Solution**: Add a delay or wait for video to be ready before showing VideoView.

### 3. Surface Not Attached
The native video surface might not be properly attached to the Flutter widget.

**Solution**: Ensure the VideoView has proper dimensions and is in the widget tree.

### 4. Participant Video Not Enabled
The remote participant might not have their video enabled yet.

**Solution**: Check `participant.videoEnabled` before showing VideoView.

## Debugging Steps

### Step 1: Check Participant Status
Add these debug logs to see participant info:
```dart
print('Participants: ${participants?.active.length}');
if (participants != null && participants.active.isNotEmpty) {
  final p = participants.active.first;
  print('Participant: ${p.name}, ID: ${p.id}, Video: ${p.videoEnabled}');
}
```

### Step 2: Check Local User Status
```dart
final localUser = service?.localUser;
print('Local user video enabled: ${localUser?.videoEnabled}');
```

### Step 3: Verify Platform View Creation
Look for these logs:
```
I/PlatformViewsController: Hosting view in view hierarchy for platform view: X
```

### Step 4: Check Video Codec
Look for these logs:
```
I/OplusFeedbackInfo: c2.mtk.vpx.decoder 640x480 inputFps=X outputFps=Y renderFps=Z
```

## Quick Fixes to Try

### Fix 1: Add Explicit Dimensions
```dart
Container(
  width: double.infinity,
  height: double.infinity,
  color: Colors.black,
  child: VideoView(
    meetingParticipant: remoteParticipant,
    isSelfParticipant: false,
  ),
)
```

### Fix 2: Add Keys for Proper Rebuild
```dart
VideoView(
  key: ValueKey('remote_${remoteParticipant.id}'),
  meetingParticipant: remoteParticipant,
  isSelfParticipant: false,
)
```

### Fix 3: Wait for Video to be Ready
```dart
if (remoteParticipant.videoEnabled) {
  return VideoView(...);
} else {
  return Text('Waiting for video...');
}
```

### Fix 4: Force Rebuild on Participant Change
```dart
// In controller, add:
final participantCount = 0.obs;

// Update when participants change:
service.participantEventStream.listen((event) {
  participantCount.value++;
});

// In UI:
Obx(() {
  final _ = controller.participantCount.value; // Trigger rebuild
  return _buildRemoteVideo();
})
```

## Alternative Approach

If VideoView continues to show black screen, try using the participant event listeners:

```dart
// In service:
_client!.addParticipantsEventListener(this);

// Implement:
@override
void onVideoUpdate(participant, videoEnabled) {
  print('Video update: ${participant.name} - $videoEnabled');
  // Trigger UI rebuild
}
```

## Known Issues

### RealtimeKit SDK Color Parsing Error
The SDK has a color parsing bug:
```
FormatException: Invalid radix-16 number (at character 3)
FF 35F2B3
```

This is in the SDK's design tokens parsing. It's trying to parse "FF 35F2B3" as a hex color but the space is causing it to fail. This shouldn't affect video rendering but might affect UI theming.

## Next Steps

1. **Add debug logs** - See what participant info we're getting
2. **Check video enabled status** - Verify both participants have video on
3. **Try without ClipRRect** - Remove any clipping that might hide the video
4. **Check native logs** - Look for Android-specific video surface errors
5. **Contact RealtimeKit support** - They might have specific Flutter integration guidance

## Test Checklist

- [ ] Can you see the platform view IDs in logs?
- [ ] Are participants showing as joined?
- [ ] Is `videoEnabled` true for both participants?
- [ ] Are video frames being encoded/decoded (check fps logs)?
- [ ] Does removing ClipRRect help?
- [ ] Does adding explicit Container dimensions help?
- [ ] Does waiting a few seconds show video?

## Expected Behavior

When working correctly:
1. Join meeting
2. See "Participant joined" log with video enabled
3. Platform views created (IDs 3, 4, etc.)
4. Video codec starts (30fps logs)
5. Video appears in VideoView widgets

## Current Behavior

1. ✅ Join meeting
2. ✅ See "Participant joined" log
3. ✅ Platform views created
4. ✅ Video codec starts
5. ❌ Black screens instead of video

The issue is in step 5 - the platform views are created and video is being processed, but not displayed.
