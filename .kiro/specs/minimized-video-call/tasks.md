# Implementation Plan: Minimized Video Call Feature

## Overview

This implementation plan breaks down the minimized video call feature into discrete coding tasks. The feature allows users to minimize an active video consultation to a floating window within the app, navigate to other screens while the call continues, and expand back to full-screen at any time.

## Tasks

- [x] 1. Create data models and enums
  - Create `MinimizedCallState` class with state properties and `formattedDuration` getter
  - Create `CornerPosition` enum with `getOffset` and `findNearest` methods
  - Add validation and helper methods
  - _Requirements: 2.1, 4.3, 4.5, 7.5_

- [ ]* 1.1 Write property test for duration formatting
  - **Property 7: Duration formatting**
  - **Validates: Requirements 7.5**

- [ ]* 1.2 Write property test for corner snapping
  - **Property 5: Corner snapping correctness**
  - **Validates: Requirements 4.3**

- [ ]* 1.3 Write unit tests for CornerPosition edge cases
  - Test position exactly at screen center
  - Test positions at quadrant boundaries
  - _Requirements: 4.3_

- [x] 2. Implement MinimizedCallManager controller
  - Create GetX controller with observable state (isCallMinimized, minimizedPosition, callDuration)
  - Implement `minimizeCall` method to create and insert overlay
  - Implement `expandCall` method to remove overlay and navigate to full screen
  - Implement `updatePosition` method for drag updates
  - Implement `_snapToNearestCorner` helper method
  - Implement `endCall` method with cleanup
  - Implement duration timer (start, stop, increment)
  - Implement proper dispose with resource cleanup
  - _Requirements: 1.1, 1.2, 3.1, 4.3, 5.3, 5.4, 5.5, 7.5_

- [ ]* 2.1 Write property test for position calculation
  - **Property 1: Position calculation correctness**
  - **Validates: Requirements 1.2, 4.5**

- [ ]* 2.2 Write property test for state preservation
  - **Property 2: State preservation during transitions**
  - **Validates: Requirements 1.3, 3.2**

- [ ]* 2.3 Write unit tests for MinimizedCallManager
  - Test minimizeCall creates overlay entry
  - Test expandCall removes overlay
  - Test endCall cleanup
  - Test duration timer increments
  - Test dispose cleanup
  - _Requirements: 1.1, 3.1, 5.3, 5.4, 5.5_

- [x] 3. Create MinimizedCallWidget UI component
  - Create stateful widget with required parameters (controller, callbacks, position)
  - Implement 120x160 container with rounded corners and shadow
  - Add VideoView for remote participant video feed
  - Add overlay gradient for text visibility
  - Add status indicators (connection, mute, camera off icons)
  - Add call duration display in MM:SS format
  - Add close button (44x44 touch target) in top-right corner
  - Implement tap gesture to expand
  - Implement long-press and drag gesture handling
  - Add haptic feedback for interactions
  - Add scale animation on tap
  - Add Semantics for accessibility
  - _Requirements: 2.1, 2.2, 2.3, 2.5, 3.1, 4.1, 4.2, 5.1, 5.2, 7.1, 7.2, 7.3, 7.4, 7.5, 8.1, 8.2, 8.3, 8.4_

- [ ]* 3.1 Write property test for drag position tracking
  - **Property 6: Drag position tracking**
  - **Validates: Requirements 4.2**

- [ ]* 3.2 Write property test for status indicator correctness
  - **Property 8: Status indicator correctness**
  - **Validates: Requirements 7.2, 7.3**

- [ ]* 3.3 Write unit tests for MinimizedCallWidget
  - Test widget renders with correct dimensions
  - Test tap triggers onTap callback
  - Test long-press enables drag
  - Test close button triggers onClose
  - Test displays correct status icons
  - _Requirements: 2.1, 3.1, 4.1, 5.1, 7.2, 7.3_

- [x] 4. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 5. Create MinimizedCallOverlay helper class
  - Implement `createOverlayEntry` static method
  - Implement `insertOverlay` static method
  - Implement `removeOverlay` static method with proper disposal
  - _Requirements: 1.2, 2.4, 3.5_

- [ ]* 5.1 Write unit tests for MinimizedCallOverlay
  - Test createOverlayEntry returns valid OverlayEntry
  - Test removeOverlay disposes entry
  - _Requirements: 1.2, 3.5_

- [x] 6. Modify RealtimeKitVideoCallScreen for minimization
  - Update PopScope onPopInvokedWithResult to call MinimizedCallManager.minimizeCall instead of showing end call dialog
  - Ensure proper context passing for overlay insertion
  - Test back button behavior during active call
  - _Requirements: 1.1_

- [ ]* 6.1 Write integration test for minimize on back button
  - Test back button during active call minimizes instead of showing dialog
  - _Requirements: 1.1_

- [x] 7. Implement navigation persistence
  - Ensure overlay remains visible across screen navigation
  - Test navigation to Dashboard, Appointments, Health Records screens
  - Verify call connection persists during navigation
  - _Requirements: 1.5, 2.4, 6.1, 6.2_

- [ ]* 7.1 Write property test for navigation persistence
  - **Property 4: Navigation persistence**
  - **Validates: Requirements 1.5, 2.4, 6.1, 6.2**

- [x] 8. Implement error handling and edge cases
  - Add connection state listener for disconnection handling
  - Show reconnection dialog on disconnection
  - Handle remote participant leaving (show notification, remove widget)
  - Handle app backgrounding (pause video, remove overlay)
  - Handle app foregrounding (resume video, re-insert overlay if call active)
  - Add check for existing minimized call before starting new call
  - Show prompt to end current call if attempting to start new one
  - _Requirements: 6.3, 6.4, 6.5, 10.1, 10.3, 10.4_

- [ ]* 8.1 Write unit tests for error handling
  - Test disconnection shows reconnection dialog
  - Test remote participant leave removes widget
  - Test app backgrounding pauses video
  - Test existing call check before new call
  - _Requirements: 6.3, 6.4, 6.5, 10.1, 10.4_

- [x] 9. Implement performance optimizations
  - Reduce remote video resolution to 240p when minimized
  - Reduce local video frame rate when minimized
  - Limit minimized widget rendering to 30 FPS
  - Ensure proper resource cleanup within 2 seconds of call termination
  - _Requirements: 9.1, 9.2, 9.3, 9.5_

- [ ]* 9.1 Write unit tests for performance optimizations
  - Test video resolution changes on minimize
  - Test frame rate changes on minimize
  - Test resource cleanup timing
  - _Requirements: 9.1, 9.2, 9.5_

- [x] 10. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 11. Add animations and polish
  - Implement smooth snap animation (250ms, easeInOut)
  - Implement tap scale animation (100ms)
  - Implement pulsing connection indicator (1000ms, repeat)
  - Test animations on different devices
  - _Requirements: 4.4, 8.4_

- [x] 12. Final integration and testing
  - Test complete minimize → navigate → expand flow
  - Test drag and snap to all four corners
  - Test end call from minimized view
  - Test all error scenarios
  - Verify accessibility with screen reader
  - Test on both iOS and Android
  - _Requirements: All_

- [ ]* 12.1 Write integration tests for complete flows
  - Test minimize → navigate → expand
  - Test drag to each corner
  - Test end call from minimized
  - _Requirements: 1.1, 3.1, 4.3, 5.2, 5.3_

- [x] 13. Final checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties
- Unit tests validate specific examples and edge cases
- Integration tests validate end-to-end flows
- The implementation builds incrementally: models → manager → widget → integration → polish
