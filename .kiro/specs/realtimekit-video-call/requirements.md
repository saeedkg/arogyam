# Requirements Document

## Introduction

This feature implements a custom video call UI for doctor-patient consultations using the `realtimekit_core: ^0.1.3` library. The video call screen will be launched when a patient taps the "Join Consultation" button in the PendingConsultationScreen. The implementation will replace the current placeholder Dyte integration with a fully functional RealtimeKit-based video consultation system.

## Requirements

### Requirement 1: RealtimeKit Library Integration

**User Story:** As a developer, I want to integrate the realtimekit_core library into the project, so that I can build custom video call functionality.

#### Acceptance Criteria

1. WHEN the developer adds realtimekit_core dependency THEN the library SHALL be properly configured in pubspec.yaml
2. WHEN the app builds THEN there SHALL be no dependency conflicts
3. WHEN platform-specific permissions are required THEN they SHALL be properly configured for Android and iOS

### Requirement 2: Custom Video Call UI

**User Story:** As a patient, I want a custom video call interface with clear controls, so that I can easily manage my consultation with the doctor.

#### Acceptance Criteria

1. WHEN the video call screen loads THEN it SHALL display the remote video feed (doctor's video)
2. WHEN the video call is active THEN it SHALL display the local video feed (patient's video) as a picture-in-picture overlay
3. WHEN the patient is in a call THEN they SHALL see controls for mute/unmute microphone
4. WHEN the patient is in a call THEN they SHALL see controls for enable/disable camera
5. WHEN the patient is in a call THEN they SHALL see a button to end the call
6. WHEN the patient is in a call THEN they SHALL see the doctor's name and specialization
7. WHEN the video call UI is displayed THEN it SHALL follow the app's design system (colors, fonts, spacing)

### Requirement 3: Video Call Connection

**User Story:** As a patient, I want to seamlessly join a video consultation, so that I can connect with my doctor without technical difficulties.

#### Acceptance Criteria

1. WHEN the patient taps "Join Consultation" in PendingConsultationScreen THEN the app SHALL navigate to the video call screen
2. WHEN the video call screen initializes THEN it SHALL use the authToken, roomName, and participantId from the consultation
3. WHEN the connection is established THEN the patient SHALL see the doctor's video feed
4. WHEN the connection fails THEN the patient SHALL see an error message with retry option
5. WHEN permissions are not granted THEN the patient SHALL see a permission request dialog

### Requirement 4: Video Call Controls

**User Story:** As a patient, I want to control my audio and video during the consultation, so that I can manage my privacy and communication preferences.

#### Acceptance Criteria

1. WHEN the patient taps the microphone button THEN the microphone SHALL toggle between muted and unmuted states
2. WHEN the microphone is muted THEN the button SHALL show a visual indicator
3. WHEN the patient taps the camera button THEN the camera SHALL toggle between enabled and disabled states
4. WHEN the camera is disabled THEN the local video SHALL show a placeholder
5. WHEN the patient taps the end call button THEN a confirmation dialog SHALL appear
6. WHEN the patient confirms ending the call THEN the app SHALL disconnect and navigate back to the previous screen

### Requirement 5: Error Handling and Edge Cases

**User Story:** As a patient, I want clear feedback when issues occur during the video call, so that I understand what's happening and what actions I can take.

#### Acceptance Criteria

1. WHEN the authToken is missing or invalid THEN the app SHALL display an error message and prevent joining
2. WHEN the network connection is lost THEN the app SHALL display a reconnection indicator
3. WHEN the doctor disconnects THEN the patient SHALL be notified
4. WHEN the call ends normally THEN the patient SHALL be navigated back with a success message
5. WHEN an unexpected error occurs THEN the app SHALL log the error and show a user-friendly message

### Requirement 6: Call State Management

**User Story:** As a patient, I want the app to properly manage the call state, so that resources are cleaned up and the app remains stable.

#### Acceptance Criteria

1. WHEN the video call screen is disposed THEN all media resources SHALL be released
2. WHEN the app goes to background THEN the video call SHALL continue (if supported)
3. WHEN the app returns to foreground THEN the video call SHALL resume properly
4. WHEN the call ends THEN the controller SHALL be properly disposed
5. WHEN the user navigates away THEN a confirmation dialog SHALL appear if the call is active

### Requirement 7: UI Responsiveness and Performance

**User Story:** As a patient, I want smooth video call performance, so that I can have a quality consultation experience.

#### Acceptance Criteria

1. WHEN the video call is active THEN the UI SHALL remain responsive
2. WHEN video frames are rendered THEN there SHALL be no visible lag or stuttering
3. WHEN controls are tapped THEN they SHALL respond immediately
4. WHEN the screen rotates THEN the UI SHALL adapt appropriately
5. WHEN the call duration exceeds 30 minutes THEN performance SHALL remain stable
