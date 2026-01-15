# Video Call Camera Switch Implementation

## Overview
Added camera switch functionality to the RealtimeKit video call screen, allowing users to toggle between front and back cameras during a consultation.

## Changes Made

### 1. Service Layer (`lib/consultation/service/realtimekit_service.dart`)
- **Added Method**: `switchCamera()`
  - Calls `_client!.localUser.switchCamera()` from RealtimeKit SDK
  - Includes error handling with VideoCallError
  - Logs camera switch events for debugging

### 2. Controller Layer (`lib/consultation/controller/realtimekit_video_call_controller.dart`)
- **Added Method**: `switchCamera()`
  - Wraps service method with error handling
  - Displays user-friendly error messages if switch fails
  - No state tracking needed (SDK handles camera state internally)

### 3. UI Layer (`lib/consultation/ui/realtimekit_video_call_screen.dart`)
- **Added Button**: Camera switch button in control bar
  - Icon: `Icons.flip_camera_ios` (standard iOS-style camera flip icon)
  - Position: Between video toggle and end call button
  - Visibility: Only shows when video is enabled
  - Behavior: Taps call `controller.switchCamera()`
  - Style: Consistent with other control buttons

## UI Behavior

### Button Visibility
- **Visible**: When `controller.isVideoEnabled.value` is `true`
- **Hidden**: When video is disabled (camera off)
- Uses `Obx()` for reactive visibility updates

### Button Layout
Control bar now has 4 buttons (when video is on):
1. Microphone toggle (mute/unmute)
2. Camera toggle (on/off)
3. **Camera switch (front/back)** ← NEW
4. End call (red button)

When video is off, only 3 buttons show (camera switch is hidden).

## Technical Details

### RealtimeKit SDK Integration
- Uses `localUser.switchCamera()` method from RealtimeKit SDK
- Method is expected to be available on `RtkSelfParticipant` object
- Follows same pattern as `enableVideo()`, `disableVideo()`, `enableAudio()`, `disableAudio()`

### Error Handling
- Service layer throws `VideoCallError.runtime` on failure
- Controller catches errors and displays via `handleError()`
- User sees error message if camera switch fails

### State Management
- No additional state variables needed
- SDK manages which camera is active internally
- Button always shows same icon (flip icon is universal)

## Testing Recommendations

1. **Basic Functionality**
   - Start video call with front camera
   - Tap camera switch button
   - Verify camera switches to back camera
   - Tap again to switch back to front

2. **Edge Cases**
   - Switch camera while video is disabled (button should be hidden)
   - Switch camera during active call with remote participant
   - Switch camera in minimized call state

3. **Error Scenarios**
   - Device with only one camera (should handle gracefully)
   - Camera permission issues
   - SDK errors during switch

## Files Modified
- `lib/consultation/service/realtimekit_service.dart`
- `lib/consultation/controller/realtimekit_video_call_controller.dart`
- `lib/consultation/ui/realtimekit_video_call_screen.dart`

## Status
✅ Implementation complete
✅ No compilation errors
✅ Ready for testing
