# Requirements Document

## Introduction

This feature improves the location permission flow to use the native system permission dialog first, providing a standard user experience where users see the familiar "Allow" / "Don't Allow" buttons. The current implementation checks if location services are enabled before requesting permission, which skips the native permission prompt. This update will request permission first (triggering the native dialog), and only show custom dialogs for specific scenarios like when the user denies permission or when location services are disabled.

## Requirements

### Requirement 1

**User Story:** As a user opening the app for the first time, I want to see the standard system permission dialog asking me to allow location access, so that I can grant permission using the familiar native interface.

#### Acceptance Criteria

1. WHEN the app starts and location permission has not been requested before THEN the system SHALL immediately request location permission using the native dialog
2. WHEN the native permission dialog is shown THEN the system SHALL display "Allow" and "Don't Allow" buttons (standard system UI)
3. WHEN the user taps "Allow" THEN the system SHALL grant location permission and proceed to fetch the user's location
4. WHEN the user taps "Don't Allow" THEN the system SHALL handle the denial gracefully without showing additional dialogs immediately

### Requirement 2

**User Story:** As a user who has denied location permission, I want to see a helpful dialog explaining why location is needed, so that I can understand the benefit and choose to enable it in settings if I change my mind.

#### Acceptance Criteria

1. WHEN the user denies location permission in the native dialog THEN the system SHALL show a custom dialog explaining the benefits of enabling location
2. WHEN the custom dialog is shown THEN it SHALL include options to "Not Now" or "Open Settings"
3. WHEN the user taps "Open Settings" THEN the system SHALL open the app settings page where the user can manually enable location permission
4. WHEN the user taps "Not Now" THEN the system SHALL dismiss the dialog and continue without location

### Requirement 3

**User Story:** As a user who has permanently denied location permission, I want to be guided to settings when I try to use location features, so that I can enable permission if I've changed my mind.

#### Acceptance Criteria

1. WHEN location permission is permanently denied (deniedForever) THEN the system SHALL NOT show the native permission dialog again
2. WHEN location permission is permanently denied AND the app needs location THEN the system SHALL show a custom dialog directing the user to settings
3. WHEN the user opens settings and grants permission THEN the system SHALL detect the permission change and fetch location on next attempt

### Requirement 4

**User Story:** As a user with location permission granted but location services disabled, I want to be prompted to enable location services, so that the app can access my location.

#### Acceptance Criteria

1. WHEN location permission is granted BUT location services are disabled THEN the system SHALL show a dialog prompting to enable location services
2. WHEN the dialog is shown THEN it SHALL include options to "Not Now" or "Enable Location"
3. WHEN the user taps "Enable Location" THEN the system SHALL open the device location settings
4. WHEN the user enables location services and returns to the app THEN the system SHALL automatically retry fetching location

### Requirement 5

**User Story:** As a developer, I want the location permission flow to follow platform best practices, so that users have a consistent and trustworthy experience.

#### Acceptance Criteria

1. WHEN requesting location permission THEN the system SHALL follow the platform-specific permission flow (iOS/Android)
2. WHEN permission is denied THEN the system SHALL NOT repeatedly prompt the user on every app launch
3. WHEN permission state changes THEN the system SHALL handle all states correctly: notDetermined, denied, deniedForever, whileInUse, always
4. WHEN errors occur during permission requests THEN the system SHALL log errors and fail gracefully without crashing
