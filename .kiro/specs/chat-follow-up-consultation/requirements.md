# Requirements Document

## Introduction

This feature adds a chat follow-up option to the PendingConsultationScreen, allowing patients to initiate text-based communication with their assigned doctor. The feature also includes improvements to the app bar design to make it more professional and visually appealing. This enhances patient-doctor communication by providing an alternative to video consultations for quick questions or follow-up discussions.

## Requirements

### Requirement 1: Chat Follow-Up Button

**User Story:** As a patient, I want to start a chat conversation with my assigned doctor, so that I can ask quick questions or follow up without needing a video call.

#### Acceptance Criteria

1. WHEN the consultation screen loads AND a doctor is assigned THEN the system SHALL display a "Chat with Doctor" button below the "Join Consultation" button
2. WHEN the user taps the "Chat with Doctor" button THEN the system SHALL navigate to a chat screen with the assigned doctor
3. IF the doctor is not yet assigned THEN the system SHALL NOT display the chat button
4. WHEN the chat button is displayed THEN it SHALL have a distinct visual style (outlined or secondary style) to differentiate it from the primary "Join Consultation" button
5. WHEN the chat button is displayed THEN it SHALL include a chat icon to clearly indicate its purpose

### Requirement 2: Professional App Bar Design

**User Story:** As a patient, I want the app bar to look professional and polished, so that I have confidence in the application's quality.

#### Acceptance Criteria

1. WHEN the consultation screen loads THEN the app bar SHALL display with a clean, professional design
2. WHEN the app bar is rendered THEN it SHALL include appropriate elevation or shadow to create visual hierarchy
3. WHEN the app bar is rendered THEN it SHALL use consistent typography with proper font weights and sizing
4. WHEN the app bar is rendered THEN it SHALL include a properly styled back button with appropriate icon and touch target
5. WHEN the app bar is rendered THEN it SHALL use the app's primary color scheme consistently
6. IF additional actions are needed THEN the app bar SHALL support action buttons on the right side

### Requirement 3: Chat Navigation Integration

**User Story:** As a patient, I want to seamlessly navigate to the chat screen, so that I can quickly start communicating with my doctor.

#### Acceptance Criteria

1. WHEN the user taps the chat button THEN the system SHALL pass the necessary consultation context (appointment ID, doctor ID, doctor name) to the chat screen
2. WHEN navigating to chat THEN the system SHALL use the app's standard navigation pattern (GetX navigation)
3. WHEN the user returns from the chat screen THEN the system SHALL return to the consultation screen without data loss
4. IF the chat navigation fails THEN the system SHALL display an error message to the user

### Requirement 4: Visual Consistency and Accessibility

**User Story:** As a patient, I want the UI elements to be visually consistent and accessible, so that I can easily use the application.

#### Acceptance Criteria

1. WHEN UI elements are rendered THEN they SHALL follow the existing design system (colors, spacing, typography)
2. WHEN buttons are displayed THEN they SHALL have adequate touch targets (minimum 48x48 dp)
3. WHEN text is displayed THEN it SHALL have sufficient contrast ratios for readability
4. WHEN interactive elements are displayed THEN they SHALL provide visual feedback on interaction (ripple effects, state changes)
