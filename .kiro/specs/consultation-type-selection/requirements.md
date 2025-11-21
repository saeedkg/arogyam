# Requirements Document

## Introduction

This feature introduces a consultation type selection screen that appears between the CareDiscoveryScreen and SpecialityDoctorsScreen. The screen allows users to choose between two consultation types: "Clinic Appointment" or "Video Consultation" before proceeding to view doctors. This selection helps streamline the user experience by filtering doctors based on the consultation type preference.

The screen should be conditionally displayed - it appears when users navigate from CareDiscoveryScreen but is skipped when users access the flow through QuickActions on the dashboard (Hospital Appointment, Video Consult, or Instant Consult buttons), as these actions already imply a specific consultation type.

## Requirements

### Requirement 1: Consultation Type Selection Screen

**User Story:** As a user browsing specialities from the Care Discovery screen, I want to choose my preferred consultation type (clinic or video), so that I can see doctors who offer that specific service.

#### Acceptance Criteria

1. WHEN a user selects a speciality from CareDiscoveryScreen THEN the system SHALL display a ConsultationTypeSelectionScreen before navigating to SpecialityDoctorsScreen
2. WHEN the ConsultationTypeSelectionScreen is displayed THEN the system SHALL show two clear options: "Clinic Appointment" and "Video Consultation"
3. WHEN a user selects "Clinic Appointment" THEN the system SHALL navigate to SpecialityDoctorsScreen with consultationType parameter set to "clinic"
4. WHEN a user selects "Video Consultation" THEN the system SHALL navigate to SpecialityDoctorsScreen with consultationType parameter set to "video"
5. WHEN the ConsultationTypeSelectionScreen is displayed THEN the system SHALL show the selected speciality name in the app bar or header
6. WHEN a user taps the back button on ConsultationTypeSelectionScreen THEN the system SHALL navigate back to CareDiscoveryScreen

### Requirement 2: Skip Selection for QuickActions

**User Story:** As a user clicking on a QuickAction button (Hospital Appointment, Video Consult, or Instant Consult), I want to skip the consultation type selection screen, so that I can quickly access the relevant flow without redundant steps.

#### Acceptance Criteria

1. WHEN a user taps "Hospital Appointment" QuickAction THEN the system SHALL navigate directly to CareDiscoveryScreen and mark the consultation type as "clinic"
2. WHEN a user taps "Video Consult" QuickAction THEN the system SHALL navigate directly to CareDiscoveryScreen and mark the consultation type as "video"
3. WHEN a user navigates from CareDiscoveryScreen to a speciality AND the consultation type was pre-selected via QuickAction THEN the system SHALL skip ConsultationTypeSelectionScreen and navigate directly to SpecialityDoctorsScreen
4. WHEN a user taps "Instant Consult" QuickAction THEN the system SHALL continue with the existing instant consultation flow without changes
5. WHEN a user navigates from a QuickAction flow THEN the system SHALL pass the pre-selected consultation type to SpecialityDoctorsScreen

### Requirement 3: Consultation Type State Management

**User Story:** As a developer, I want the consultation type selection to be properly managed throughout the navigation flow, so that the correct consultation type is maintained and passed to subsequent screens.

#### Acceptance Criteria

1. WHEN a consultation type is selected (either via ConsultationTypeSelectionScreen or QuickAction) THEN the system SHALL store this selection in the navigation flow
2. WHEN navigating to SpecialityDoctorsScreen THEN the system SHALL receive the consultationType parameter
3. WHEN a user navigates back from SpecialityDoctorsScreen to CareDiscoveryScreen THEN the system SHALL clear the consultation type selection
4. WHEN ConsultationFlowManager starts a flow THEN the system SHALL accept an optional consultationType parameter
5. IF no consultationType is provided to SpecialityDoctorsScreen THEN the system SHALL default to showing all doctors (backward compatibility)

### Requirement 4: UI/UX Design

**User Story:** As a user, I want the consultation type selection screen to be visually clear and easy to use, so that I can quickly make my choice without confusion.

#### Acceptance Criteria

1. WHEN the ConsultationTypeSelectionScreen is displayed THEN the system SHALL show two prominent, equally-sized selection cards
2. WHEN displaying selection options THEN each card SHALL include an icon, title, and brief description
3. WHEN a user hovers or taps on a selection card THEN the system SHALL provide visual feedback (highlight, shadow, or animation)
4. WHEN the screen is displayed THEN the system SHALL use consistent styling with the rest of the application (colors, fonts, spacing)
5. WHEN displaying the "Clinic Appointment" option THEN the system SHALL use an appropriate icon (e.g., hospital, clinic building)
6. WHEN displaying the "Video Consultation" option THEN the system SHALL use an appropriate icon (e.g., video camera, monitor)

### Requirement 5: Integration with Existing Flow

**User Story:** As a developer, I want the new consultation type selection to integrate seamlessly with the existing consultation flow, so that existing functionality remains unaffected.

#### Acceptance Criteria

1. WHEN implementing the ConsultationTypeSelectionScreen THEN the system SHALL not break existing navigation flows
2. WHEN a user accesses SpecialityDoctorsScreen from other entry points THEN the system SHALL continue to work as before
3. WHEN ConsultationFlowManager is updated THEN the system SHALL maintain backward compatibility with existing method signatures
4. WHEN the consultation type is passed to SpecialityDoctorsScreen THEN the system SHALL use it to filter or display relevant doctors
5. WHEN updating the routing THEN the system SHALL add the new screen route to AppRoutes if using named routes
