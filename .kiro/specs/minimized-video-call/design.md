# Design Document: Minimized Video Call Feature

## Overview

This design implements a WhatsApp-style minimized video call feature that allows users to minimize an active video consultation to a floating window within the app. The feature enables users to navigate to other screens while maintaining the video call connection, with the ability to expand back to full-screen at any time.

The implementation uses Flutter's Overlay system to display a persistent floating widget across all app screens. The design maintains separation between the video call logic (already implemented in RealtimeKitVideoCallController) and the new minimization UI layer.

### Key Design Principles

1. **Non-intrusive**: The minimized widget should be small and positioned to avoid obstructing important content
2. **Persistent**: The widget must remain visible across all in-app navigation
3. **Performant**: Minimize resource usage when the call is minimized
4. **Stateful**: Maintain call state and video connection seamlessly during minimize/expand transitions
5. **In-app only**: The minimized widget is only visible within the app, not system-wide

## Architecture

### Component Structure

```
┌─────────────────────────────────────────────────────────────┐
│                     App Root (MaterialApp)                   │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Navigator Stack                          │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │         Current Screen (Dashboard, etc.)        │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
│  ┌───────────────────────────────────────────────────────┐  │
│  │              Overlay Layer                            │  │
│  │  ┌─────────────────────────────────────────────────┐  │  │
│  │  │    MinimizedCallWidget (if call is minimized)   │  │  │
│  │  │    - Video feed                                 │  │  │
│  │  │    - Call duration                              │  │  │
│  │  │    - Status indicators                          │  │  │
│  │  │    - Close button                               │  │  │
│  │  └─────────────────────────────────────────────────┘  │  │
│  └───────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### State Management Architecture

```
┌──────────────────────────────────────────────────────────────┐
│           MinimizedCallManager (GetX Controller)             │
│  - isCallMinimized: RxBool                                   │
│  - minimizedPosition: Rx<Offset>                             │
│  - overlayEntry: OverlayEntry?                               │
│  - videoCallController: RealtimeKitVideoCallController?      │
│  + minimizeCall()                                            │
│  + expandCall()                                              │
│  + updatePosition()                                          │
│  + endCall()                                                 │
└──────────────────────────────────────────────────────────────┘
                            │
                            │ manages
                            ▼
┌──────────────────────────────────────────────────────────────┐
│              RealtimeKitVideoCallController                  │
│  - isConnected: RxBool                                       │
│  - isAudioEnabled: RxBool                                    │
│  - isVideoEnabled: RxBool                                    │
│  - service: RealtimeKitService                               │
│  + toggleAudio()                                             │
│  + toggleVideo()                                             │
│  + endCall()                                                 │
└──────────────────────────────────────────────────────────────┘
```

## Components and Interfaces

### 1. MinimizedCallManager

A singleton GetX controller that manages the minimized call state and overlay lifecycle.

```dart
class MinimizedCallManager extends GetxController {
  // Observable state
  final isCallMinimized = false.obs;
  final minimizedPosition = Rx<Offset>(Offset.zero);
  final callDuration = 0.obs;
  
  // References
  OverlayEntry? _overlayEntry;
  RealtimeKitVideoCallController? _videoCallController;
  Timer? _durationTimer;
  
  // Methods
  Future<void> minimizeCall(
    BuildContext context,
    RealtimeKitVideoCallController controller
  );
  
  Future<void> expandCall(BuildContext context);
  
  void updatePosition(Offset newPosition);
  
  Offset _snapToNearestCorner(Offset position, Size screenSize);
  
  Future<void> endCall();
  
  void _startDurationTimer();
  
  void _stopDurationTimer();
  
  void dispose();
}
```

**Responsibilities:**
- Manage the overlay entry lifecycle (create, update, remove)
- Track minimized state and position
- Handle minimize/expand transitions
- Coordinate with video call controller
- Track and format call duration

### 2. MinimizedCallWidget

A stateful widget that renders the floating minimized call window.

```dart
class MinimizedCallWidget extends StatefulWidget {
  final RealtimeKitVideoCallController controller;
  final VoidCallback onTap;
  final VoidCallback onClose;
  final Offset position;
  final Function(Offset) onDragUpdate;
  
  const MinimizedCallWidget({
    required this.controller,
    required this.onTap,
    required this.onClose,
    required this.position,
    required this.onDragUpdate,
  });
}
```

**UI Structure:**
- Container: 120x160 pixels with rounded corners (12px radius)
- Remote video feed (using VideoView from RealtimeKit)
- Overlay gradient for better text visibility
- Status indicators (connection, mute, camera off)
- Call duration display (MM:SS format)
- Close button (top-right corner, 44x44 touch target)
- Drag handle (long-press to activate)

**Interactions:**
- Tap: Expand to full screen
- Long-press + drag: Move widget
- Tap close button: Show end call confirmation
- Haptic feedback on interactions

### 3. RealtimeKitVideoCallScreen (Modified)

Update the existing video call screen to support minimization.

```dart
class RealtimeKitVideoCallScreen extends StatefulWidget {
  // Existing code...
  
  // Add minimization support in PopScope
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (controller.isConnected.value) {
          // NEW: Minimize instead of showing end call dialog
          await Get.find<MinimizedCallManager>().minimizeCall(
            context,
            controller
          );
        } else {
          Navigator.of(context).pop();
        }
      },
      child: // existing scaffold...
    );
  }
}
```

### 4. MinimizedCallOverlay

A helper class to manage overlay insertion and removal.

```dart
class MinimizedCallOverlay {
  static OverlayEntry createOverlayEntry({
    required RealtimeKitVideoCallController controller,
    required VoidCallback onExpand,
    required VoidCallback onClose,
    required Offset position,
    required Function(Offset) onDragUpdate,
  }) {
    return OverlayEntry(
      builder: (context) => MinimizedCallWidget(
        controller: controller,
        onTap: onExpand,
        onClose: onClose,
        position: position,
        onDragUpdate: onDragUpdate,
      ),
    );
  }
  
  static void insertOverlay(
    BuildContext context,
    OverlayEntry entry,
  ) {
    Overlay.of(context).insert(entry);
  }
  
  static void removeOverlay(OverlayEntry? entry) {
    entry?.remove();
    entry?.dispose();
  }
}
```

## Data Models

### MinimizedCallState

```dart
class MinimizedCallState {
  final bool isMinimized;
  final Offset position;
  final int durationSeconds;
  final bool isConnected;
  final bool isAudioMuted;
  final bool isVideoDisabled;
  
  MinimizedCallState({
    required this.isMinimized,
    required this.position,
    required this.durationSeconds,
    required this.isConnected,
    required this.isAudioMuted,
    required this.isVideoDisabled,
  });
  
  MinimizedCallState copyWith({
    bool? isMinimized,
    Offset? position,
    int? durationSeconds,
    bool? isConnected,
    bool? isAudioMuted,
    bool? isVideoDisabled,
  });
  
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
}
```

### CornerPosition

```dart
enum CornerPosition {
  topLeft,
  topRight,
  bottomLeft,
  bottomRight;
  
  Offset getOffset(Size screenSize, Size widgetSize, double padding) {
    switch (this) {
      case CornerPosition.topLeft:
        return Offset(padding, padding);
      case CornerPosition.topRight:
        return Offset(screenSize.width - widgetSize.width - padding, padding);
      case CornerPosition.bottomLeft:
        return Offset(padding, screenSize.height - widgetSize.height - padding);
      case CornerPosition.bottomRight:
        return Offset(
          screenSize.width - widgetSize.width - padding,
          screenSize.height - widgetSize.height - padding,
        );
    }
  }
  
  static CornerPosition findNearest(Offset position, Size screenSize) {
    final centerX = screenSize.width / 2;
    final centerY = screenSize.height / 2;
    
    final isLeft = position.dx < centerX;
    final isTop = position.dy < centerY;
    
    if (isTop && isLeft) return CornerPosition.topLeft;
    if (isTop && !isLeft) return CornerPosition.topRight;
    if (!isTop && isLeft) return CornerPosition.bottomLeft;
    return CornerPosition.bottomRight;
  }
}
```


## Correctness Properties

*A property is a characteristic or behavior that should hold true across all valid executions of a system—essentially, a formal statement about what the system should do. Properties serve as the bridge between human-readable specifications and machine-verifiable correctness guarantees.*

### Property 1: Position calculation correctness
*For any* screen size, when the call is minimized, the widget position should be in the bottom-right corner with exactly 16 pixels padding from both edges.
**Validates: Requirements 1.2, 4.5**

### Property 2: State preservation during transitions
*For any* call state (connected, audio enabled/disabled, video enabled/disabled), minimizing and then expanding should preserve all state values without interruption.
**Validates: Requirements 1.3, 3.2**

### Property 3: Video feed display
*For any* minimized call, the widget should contain a VideoView component displaying the remote participant's video feed.
**Validates: Requirements 1.4, 2.2**

### Property 4: Navigation persistence
*For any* navigation action to a different screen within the app, the minimized widget should remain visible in the overlay layer and the call connection should remain active.
**Validates: Requirements 1.5, 2.4, 6.1, 6.2**

### Property 5: Corner snapping correctness
*For any* drag release position on the screen, the widget should snap to the nearest corner (top-left, top-right, bottom-left, or bottom-right) based on which quadrant the position falls into.
**Validates: Requirements 4.3**

### Property 6: Drag position tracking
*For any* drag gesture, the widget position should update to match the finger position in real-time.
**Validates: Requirements 4.2**

### Property 7: Duration formatting
*For any* duration in seconds, the formatted duration string should match the MM:SS format where minutes and seconds are zero-padded to 2 digits.
**Validates: Requirements 7.5**

### Property 8: Status indicator correctness
*For any* call state, the widget should display the correct status icons: muted microphone icon when audio is muted, camera-off icon when video is disabled.
**Validates: Requirements 7.2, 7.3**

### Property 9: Widget dimensions
*For any* rendering of the minimized widget, the dimensions should be exactly 120 pixels wide and 160 pixels tall.
**Validates: Requirements 2.1**

### Property 10: Overlay removal on expansion
*For any* expansion action, the overlay entry should be removed and disposed, and the full-screen video call screen should be displayed.
**Validates: Requirements 3.5**

## Error Handling

### Connection Errors

**Disconnection during minimized state:**
- Listen to connection state changes from RealtimeKitService
- When disconnected, show a reconnection dialog overlay
- Provide options: "Reconnect" or "End Call"
- If reconnection fails after 3 attempts, automatically end call and remove widget

**Network quality degradation:**
- Monitor connection quality from RealtimeKitService
- Show a warning indicator on the minimized widget if quality is poor
- Automatically reduce video quality to maintain connection

### Resource Management Errors

**Memory pressure:**
- Listen to system memory warnings
- Reduce video quality or pause video feed if memory is critically low
- Prioritize audio connection over video
- Log memory pressure events for debugging

**Overlay insertion failure:**
- Catch exceptions during overlay insertion
- Fall back to showing end call dialog if overlay cannot be created
- Log error for debugging

### User Interaction Errors

**Attempting to start new call while one is minimized:**
- Check if MinimizedCallManager has an active minimized call
- Show dialog: "You have an active call. End current call to start a new one?"
- Provide options: "End Current Call" or "Cancel"

**App backgrounding:**
- Listen to AppLifecycleState changes
- When app goes to background (paused/inactive):
  - Pause video feeds (both local and remote)
  - Maintain audio connection
  - Remove overlay (since it's in-app only)
- When app returns to foreground (resumed):
  - Resume video feeds
  - Re-insert overlay if call is still active

**Force close / app termination:**
- Implement proper cleanup in MinimizedCallManager.dispose()
- Ensure RealtimeKitService.leaveMeeting() is called
- Remove overlay entry
- Cancel duration timer

### Edge Cases

**Remote participant ends call:**
- Listen to participant leave events from RealtimeKitService
- Remove minimized widget immediately
- Show snackbar notification: "Call ended by {participant name}"
- Clean up all resources

**Incoming phone call:**
- Listen to phone call interruption events (platform-specific)
- Pause video call automatically
- Show notification: "Video call paused due to incoming phone call"
- Resume when phone call ends

**Screen rotation:**
- Recalculate widget position based on new screen dimensions
- Maintain the same corner position (e.g., if in bottom-right, stay in bottom-right)
- Animate to new position smoothly

## Testing Strategy

### Unit Tests

Unit tests will verify specific examples, edge cases, and error conditions:

**MinimizedCallManager Tests:**
- Test minimizeCall creates overlay entry
- Test expandCall removes overlay and navigates to full screen
- Test updatePosition updates the position observable
- Test snapToNearestCorner with specific positions (center of each quadrant)
- Test endCall cleans up resources
- Test duration timer increments correctly
- Test dispose cleans up all resources

**MinimizedCallState Tests:**
- Test formattedDuration with specific values (0, 59, 60, 3599, 3600)
- Test copyWith creates new instance with updated values

**CornerPosition Tests:**
- Test getOffset returns correct position for each corner
- Test findNearest returns correct corner for positions in each quadrant
- Test edge case: position exactly at screen center

**MinimizedCallWidget Tests:**
- Test widget renders with correct dimensions (120x160)
- Test tap gesture triggers onTap callback
- Test long-press enables drag mode
- Test close button tap triggers onClose callback
- Test widget displays correct status icons based on controller state

### Property-Based Tests

Property-based tests will verify universal properties across all inputs. Each test should run a minimum of 100 iterations.

**Property Test 1: Position calculation correctness**
- Generate random screen sizes (width: 320-2000, height: 568-3000)
- Calculate bottom-right position
- Verify: x = screenWidth - 120 - 16, y = screenHeight - 160 - 16
- **Feature: minimized-video-call, Property 1: Position calculation correctness**

**Property Test 2: State preservation during transitions**
- Generate random call states (connected: true/false, audio: true/false, video: true/false)
- Minimize call with that state
- Expand call
- Verify: all state values match original state
- **Feature: minimized-video-call, Property 2: State preservation during transitions**

**Property Test 3: Corner snapping correctness**
- Generate random drag release positions across the screen
- Calculate nearest corner
- Verify: position is in the correct quadrant for that corner
- **Feature: minimized-video-call, Property 5: Corner snapping correctness**

**Property Test 4: Duration formatting**
- Generate random durations (0 to 86400 seconds)
- Format duration
- Verify: matches MM:SS format with zero-padding
- Parse formatted string and verify it matches original duration
- **Feature: minimized-video-call, Property 7: Duration formatting**

**Property Test 5: Navigation persistence**
- Generate random navigation sequences (list of screen names)
- Minimize call
- Navigate through each screen
- Verify: overlay remains present after each navigation
- Verify: call connection remains active
- **Feature: minimized-video-call, Property 4: Navigation persistence**

**Property Test 6: Drag position tracking**
- Generate random drag gesture sequences (list of positions)
- Simulate drag with those positions
- Verify: widget position updates to match each position in sequence
- **Feature: minimized-video-call, Property 6: Drag position tracking**

### Integration Tests

Integration tests will verify the feature works correctly with the existing video call system:

- Test minimize from full-screen video call
- Test expand back to full-screen
- Test end call from minimized view
- Test navigation to different screens while minimized
- Test drag and snap to different corners
- Test connection state changes while minimized
- Test app backgrounding and foregrounding

### Testing Framework

- **Unit Tests**: Flutter's built-in test framework
- **Property-Based Tests**: Use `test` package with custom generators for random data
- **Integration Tests**: Flutter integration_test package
- **Widget Tests**: Flutter widget testing with `flutter_test`

### Test Data Generators

For property-based tests, implement custom generators:

```dart
// Generate random screen sizes
Size generateScreenSize() {
  final random = Random();
  return Size(
    320 + random.nextDouble() * 1680, // 320 to 2000
    568 + random.nextDouble() * 2432, // 568 to 3000
  );
}

// Generate random positions
Offset generatePosition(Size screenSize) {
  final random = Random();
  return Offset(
    random.nextDouble() * screenSize.width,
    random.nextDouble() * screenSize.height,
  );
}

// Generate random call states
CallState generateCallState() {
  final random = Random();
  return CallState(
    isConnected: random.nextBool(),
    isAudioEnabled: random.nextBool(),
    isVideoEnabled: random.nextBool(),
  );
}

// Generate random durations
int generateDuration() {
  final random = Random();
  return random.nextInt(86400); // 0 to 24 hours
}
```

## Implementation Notes

### Performance Considerations

1. **Video Resolution**: When minimized, reduce remote video resolution to 240p to conserve bandwidth
2. **Frame Rate**: Limit minimized widget rendering to 30 FPS maximum
3. **Overlay Updates**: Use `setState` sparingly, only update when position or state actually changes
4. **Memory**: Ensure proper disposal of overlay entries and controllers

### Platform-Specific Considerations

**iOS:**
- Use `SystemChrome.setEnabledSystemUIMode` to handle status bar visibility
- Handle CallKit integration for incoming phone calls
- Test with iOS picture-in-picture system to ensure no conflicts

**Android:**
- Handle system back button properly (should minimize, not close)
- Test with Android picture-in-picture to ensure no conflicts
- Handle notification permissions for call ended notifications

### Accessibility

- Add Semantics widgets with appropriate labels
- Ensure minimum touch target size (44x44) for all interactive elements
- Provide haptic feedback for interactions
- Support screen readers with descriptive labels

### Animation

- Use `AnimatedPositioned` for smooth position transitions during snap
- Duration: 250ms with `Curves.easeInOut`
- Scale animation on tap: scale from 1.0 to 0.95 and back (100ms)
- Pulsing connection indicator: opacity animation from 1.0 to 0.5 (1000ms, repeat)

### State Management

- Use GetX for reactive state management
- MinimizedCallManager as singleton controller
- Expose observables for UI to react to state changes
- Ensure proper cleanup in dispose methods

### Dependencies

No new dependencies required. The implementation uses:
- Flutter SDK (existing)
- GetX (existing)
- RealtimeKit SDK (existing)
- flutter_test (for testing)
