# Requirements Document: Minimized Video Call Feature

## Introduction

This feature enables users to minimize an active video consultation call to a small floating window within the app, similar to WhatsApp's picture-in-picture functionality. Users can navigate to other screens while the call continues, and tap the floating window to return to the full-screen call view.

## Glossary

- **Video_Call_Screen**: The full-screen video consultation interface showing doctor and patient video feeds
- **Minimized_Call_Widget**: A small floating window displaying the ongoing video call
- **Call_State_Manager**: Service that maintains the active call state across screen navigation
- **Overlay_Service**: System that manages floating widgets displayed over other screens
- **Expand_Action**: User interaction to return from minimized view to full-screen call
- **Minimize_Action**: User interaction to reduce full-screen call to floating window

## Requirements

### Requirement 1: Minimize Video Call

**User Story:** As a user in an active video consultation, I want to minimize the call to a small window, so that I can navigate to other parts of the app while continuing the consultation.

#### Acceptance Criteria

1. WHEN a user presses the back button during an active video call, THE System SHALL minimize the call to a floating window instead of showing the end call confirmation
2. WHEN the call is minimized, THE Minimized_Call_Widget SHALL appear in the bottom-right corner of the screen
3. WHEN the call is minimized, THE System SHALL maintain the video and audio connection without interruption
4. WHEN the call is minimized, THE Minimized_Call_Widget SHALL display the remote participant's video feed
5. WHEN the call is minimized, THE System SHALL allow navigation to any screen within the app

### Requirement 2: Floating Window Display

**User Story:** As a user with a minimized call, I want to see a compact floating window showing the ongoing call, so that I remain aware of the active consultation.

#### Acceptance Criteria

1. THE Minimized_Call_Widget SHALL display at 120x160 pixels in size
2. THE Minimized_Call_Widget SHALL show the remote participant's video feed
3. THE Minimized_Call_Widget SHALL display a small indicator showing call duration
4. THE Minimized_Call_Widget SHALL remain visible on top of all other app screens
5. THE Minimized_Call_Widget SHALL have rounded corners and a subtle shadow for visual distinction

### Requirement 3: Expand to Full Screen

**User Story:** As a user with a minimized call, I want to tap the floating window to return to full-screen view, so that I can resume normal video consultation interaction.

#### Acceptance Criteria

1. WHEN a user taps the Minimized_Call_Widget, THE System SHALL expand the call back to full-screen Video_Call_Screen
2. WHEN expanding to full screen, THE System SHALL maintain the video and audio connection without interruption
3. WHEN expanding to full screen, THE System SHALL restore all call controls (mute, camera toggle, end call)
4. WHEN expanding to full screen, THE System SHALL display both local and remote video feeds
5. WHEN expanding to full screen, THE System SHALL remove the Minimized_Call_Widget from display

### Requirement 4: Draggable Floating Window

**User Story:** As a user with a minimized call, I want to drag the floating window to a different position, so that it doesn't obstruct content I'm viewing.

#### Acceptance Criteria

1. WHEN a user long-presses the Minimized_Call_Widget, THE System SHALL enable drag mode
2. WHILE dragging, THE Minimized_Call_Widget SHALL follow the user's finger position
3. WHEN the user releases the drag, THE Minimized_Call_Widget SHALL snap to the nearest corner (top-left, top-right, bottom-left, bottom-right)
4. WHEN snapping to a corner, THE System SHALL animate the movement smoothly
5. THE Minimized_Call_Widget SHALL maintain 16 pixels padding from screen edges

### Requirement 5: End Call from Minimized View

**User Story:** As a user with a minimized call, I want to end the call without expanding to full screen, so that I can quickly terminate the consultation.

#### Acceptance Criteria

1. THE Minimized_Call_Widget SHALL display a small close/end button
2. WHEN a user taps the end button on Minimized_Call_Widget, THE System SHALL show an end call confirmation dialog
3. WHEN the user confirms ending the call, THE System SHALL terminate the video connection
4. WHEN the call ends, THE System SHALL remove the Minimized_Call_Widget from display
5. WHEN the call ends, THE System SHALL clean up all video call resources

### Requirement 6: Call State Persistence

**User Story:** As a user with a minimized call, I want the call to continue seamlessly as I navigate between screens, so that my consultation is not interrupted.

#### Acceptance Criteria

1. WHEN a user navigates to a different screen, THE System SHALL maintain the active call connection
2. WHEN a user navigates to a different screen, THE Minimized_Call_Widget SHALL remain visible and functional
3. WHEN the remote participant ends the call, THE System SHALL remove the Minimized_Call_Widget and show a notification
4. WHEN the call is disconnected due to network issues, THE System SHALL show an error notification and remove the Minimized_Call_Widget
5. WHEN the app is backgrounded (user switches to another app), THE System SHALL pause the video feeds but maintain the audio connection

### Requirement 7: Visual Feedback and Indicators

**User Story:** As a user with a minimized call, I want visual indicators showing the call status, so that I know the consultation is active and functioning properly.

#### Acceptance Criteria

1. THE Minimized_Call_Widget SHALL display a pulsing green indicator when the call is connected
2. THE Minimized_Call_Widget SHALL display a muted microphone icon when audio is muted
3. THE Minimized_Call_Widget SHALL display a camera-off icon when video is disabled
4. WHEN the remote participant's video is disabled, THE Minimized_Call_Widget SHALL show their profile picture
5. THE Minimized_Call_Widget SHALL display the call duration in MM:SS format

### Requirement 8: Accessibility and Interaction

**User Story:** As a user with a minimized call, I want clear and accessible controls, so that I can easily manage the call regardless of my technical proficiency.

#### Acceptance Criteria

1. THE Minimized_Call_Widget SHALL have a minimum touch target size of 44x44 pixels for all interactive elements
2. THE Minimized_Call_Widget SHALL provide haptic feedback when tapped or dragged
3. THE Minimized_Call_Widget SHALL be accessible via screen readers with appropriate labels
4. WHEN the Minimized_Call_Widget is tapped, THE System SHALL provide visual feedback (scale animation)
5. THE Minimized_Call_Widget SHALL not interfere with navigation gestures (back swipe, etc.)

### Requirement 9: Performance and Resource Management

**User Story:** As a user with a minimized call, I want the app to remain responsive and not drain battery excessively, so that I can use other features without performance degradation.

#### Acceptance Criteria

1. WHEN the call is minimized, THE System SHALL reduce the remote video resolution to conserve bandwidth
2. WHEN the call is minimized, THE System SHALL reduce the local video frame rate to conserve battery
3. THE Minimized_Call_Widget SHALL render at 30 FPS maximum
4. WHEN navigating between screens, THE System SHALL maintain smooth 60 FPS animations
5. THE System SHALL release video resources within 2 seconds of call termination

### Requirement 10: Edge Cases and Error Handling

**User Story:** As a user, I want the minimized call feature to handle unexpected situations gracefully, so that I don't lose my consultation or experience crashes.

#### Acceptance Criteria

1. WHEN the call is disconnected while minimized, THE System SHALL show a reconnection dialog
2. WHEN the user receives a phone call while in a minimized video call, THE System SHALL pause the video call and show a notification
3. WHEN the app is force-closed, THE System SHALL properly terminate the call and clean up resources
4. WHEN the user tries to start a new video call while one is minimized, THE System SHALL prompt to end the current call first
5. WHEN memory is low, THE System SHALL prioritize the active call over other app features
