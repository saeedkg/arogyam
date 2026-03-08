# Requirements Document

## Introduction

This document outlines the requirements for fixing critical issues with the RealtimeKit video call integration in the Arogyam telemedicine app. The current implementation has connection problems where patients cannot reliably join meetings, sessions don't appear in the RealtimeKit dashboard, and the app requires force-closing between calls.

## Requirements

### Requirement 1: Reliable Meeting Connection to Cloudflare

**User Story:** As a patient, I want to successfully connect to video consultations on the first attempt, so that I can start my appointment without technical difficulties and my session appears in the Cloudflare dashboard.

#### Acceptance Criteria

1. WHEN a patient taps "Join Consultation" THEN the app SHALL establish a connection to the Cloudflare RealtimeKit server within 10 seconds
2. WHEN a connection is established THEN a new session SHALL appear in the Cloudflare dashboard (https://dash.cloudflare.com/)
3. WHEN a patient joins an existing meeting THEN they SHALL join the existing session visible in the dashboard
4. WHEN the connection fails THEN the app SHALL display a clear error message with the specific failure reason
5. IF the auth token is invalid THEN the app SHALL show "Authentication failed" error
6. IF the network is unavailable THEN the app SHALL show "Network connection error"
7. WHEN a patient joins a meeting THEN the RealtimeKit client SHALL be properly initialized with all required parameters
8. WHEN the SDK connects THEN it SHALL use a fresh client instance without cached state from previous calls

### Requirement 2: Complete Client Disposal Between Calls

**User Story:** As a patient, I want to join multiple consultations in sequence without restarting the app, so that I can have a seamless experience when scheduling back-to-back appointments.

#### Acceptance Criteria

1. WHEN a patient ends a video call THEN all RealtimeKit client resources SHALL be completely disposed and nullified
2. WHEN a patient joins a second call after ending the first THEN the connection SHALL succeed and appear in Cloudflare dashboard
3. WHEN the service is disposed THEN the client instance SHALL be completely destroyed and set to null
4. WHEN the service is disposed THEN all event listeners SHALL be removed from the client
5. WHEN the service is disposed THEN all native listeners SHALL be cleaned via cleanAllNativeListeners()
6. WHEN the service is disposed THEN all stream controllers SHALL be closed and disposed
7. WHEN initializing a new meeting THEN the service SHALL verify no previous client instance exists
8. IF a previous client exists THEN the service SHALL completely dispose it before creating a new one
9. WHEN a new client is created THEN it SHALL have no cached state or references from previous sessions
10. WHEN leaving a meeting THEN the app SHALL wait for the leave operation to complete before disposing resources

### Requirement 3: Proper Logging and Debugging

**User Story:** As a developer, I want clear, structured logging during video call operations, so that I can quickly diagnose and fix connection issues.

#### Acceptance Criteria

1. WHEN the app starts a video call operation THEN all existing debug print statements SHALL be removed
2. WHEN logging is needed THEN the app SHALL use a proper logging framework (logger package)
3. WHEN a meeting is initialized THEN the app SHALL log: initialization start, auth token (first 10 chars), room name, participant ID
4. WHEN SDK callbacks are triggered THEN the app SHALL log the callback name and relevant data
5. WHEN errors occur THEN the app SHALL log the error type, message, and stack trace
6. WHEN a meeting is joined successfully THEN the app SHALL log participant count and connection status
7. WHEN the service is disposed THEN the app SHALL log each cleanup step
8. IF verbose logging is disabled THEN only error and warning logs SHALL be shown

### Requirement 4: Correct SDK Usage According to Documentation

**User Story:** As a developer, I want the RealtimeKit SDK to be used according to official documentation, so that the integration works reliably and is maintainable.

#### Acceptance Criteria

1. WHEN initializing the client THEN the app SHALL follow the official RealtimeKit Core documentation pattern
2. WHEN creating RtkMeetingInfo THEN all required parameters SHALL be provided
3. WHEN joining a room THEN the app SHALL wait for `onMeetingInitCompleted` callback before calling `joinRoom()`
4. WHEN the app uses workarounds THEN they SHALL be removed and replaced with proper SDK usage
5. WHEN event listeners are added THEN they SHALL be added before calling `init()`
6. WHEN the meeting is initialized THEN the app SHALL NOT manually force connection state changes
7. WHEN callbacks fire THEN the app SHALL rely on SDK callbacks for state management

### Requirement 5: Proper Resource Cleanup and State Management

**User Story:** As a patient, I want the app to properly clean up resources after each call, so that subsequent calls work correctly and the app doesn't consume excessive memory.

#### Acceptance Criteria

1. WHEN a call ends THEN the service SHALL call `leaveRoom()` before disposal
2. WHEN `leaveRoom()` is called THEN the app SHALL wait for `onMeetingRoomLeaveCompleted` callback
3. WHEN disposing the service THEN the app SHALL remove all event listeners before cleaning native listeners
4. WHEN disposing the service THEN the app SHALL close all stream controllers
5. WHEN disposing the service THEN the app SHALL set the client reference to null
6. WHEN a new meeting is initialized THEN the service SHALL verify it's in a clean state
7. IF the service is not in a clean state THEN it SHALL perform cleanup before initialization

### Requirement 6: Update to Latest RealtimeKit Version

**User Story:** As a developer, I want to use the latest stable version of RealtimeKit, so that I benefit from bug fixes and improvements.

#### Acceptance Criteria

1. WHEN updating dependencies THEN the app SHALL use the latest stable version of realtimekit_core
2. WHEN the version is updated THEN the pubspec.yaml SHALL reflect the new version constraint
3. WHEN the version is updated THEN any deprecated API usage SHALL be updated to current APIs
4. WHEN the version is updated THEN the app SHALL be tested to ensure compatibility

### Requirement 7: iOS Platform Support

**User Story:** As a patient using an iPhone, I want video consultations to work properly on iOS, so that I can have the same experience as Android users.

#### Acceptance Criteria

1. WHEN building for iOS THEN the fake plugin override SHALL be removed from pubspec.yaml
2. WHEN the app runs on iOS THEN camera and microphone permissions SHALL be properly requested
3. WHEN the app runs on iOS THEN video calls SHALL connect to RealtimeKit server
4. WHEN the app runs on iOS THEN all SDK callbacks SHALL fire correctly
5. WHEN building for iOS THEN the Podfile SHALL have correct minimum iOS version (15.0+)
6. WHEN building for iOS THEN Swift version SHALL be 5.0 or higher
7. IF background audio is needed THEN UIBackgroundModes SHALL be configured in Info.plist
8. WHEN developing on Windows THEN the fake plugin override MAY be used for development
9. WHEN preparing iOS builds THEN documentation SHALL clearly explain the override removal process

