# Requirements Document

## Introduction

This feature enables automatic OTP reading and auto-filling functionality in the EnterOtpScreen. When users receive an SMS containing their verification code from CP-ASKIT-T with the message format "Your ASKIT health verification code is [6-digit code]. Valid for 5 minutes. Do not share with anyone.", the application will automatically detect, extract, and fill the OTP into the input fields, improving user experience and reducing manual entry errors.

## Requirements

### Requirement 1: Automatic SMS Detection and OTP Extraction

**User Story:** As a user receiving an OTP via SMS, I want the app to automatically detect and extract the verification code, so that I don't have to manually switch apps and type the code.

#### Acceptance Criteria

1. WHEN the app is on the EnterOtpScreen AND an SMS arrives from CP-ASKIT-T THEN the system SHALL automatically detect the incoming SMS
2. WHEN an SMS is detected THEN the system SHALL extract the 6-digit verification code from the message body
3. WHEN the message format matches "Your ASKIT health verification code is [code]. Valid for 5 minutes. Do not share with anyone." THEN the system SHALL successfully parse the OTP
4. WHEN the OTP is extracted THEN the system SHALL validate that it contains exactly 6 numeric digits
5. IF the SMS does not match the expected format OR does not contain a valid 6-digit code THEN the system SHALL ignore the message and not attempt auto-fill

### Requirement 2: Automatic OTP Field Population

**User Story:** As a user, I want the extracted OTP to be automatically filled into the input fields, so that I can proceed with verification without manual typing.

#### Acceptance Criteria

1. WHEN a valid OTP is extracted from SMS THEN the system SHALL automatically populate all 6 OTP input fields with the corresponding digits
2. WHEN the OTP fields are auto-filled THEN the system SHALL trigger the validation logic to verify the OTP format
3. WHEN all fields are populated THEN the system SHALL enable the "Verify & Continue" button if the OTP is valid
4. WHEN auto-fill completes THEN the system SHALL dismiss the keyboard automatically
5. IF the user has already started manually entering the OTP THEN the system SHALL NOT override the existing input with auto-filled values

### Requirement 3: SMS Permission Handling

**User Story:** As a user, I want to be informed about SMS permission requirements, so that I understand why the app needs access to my messages and can make an informed decision.

#### Acceptance Criteria

1. WHEN the app starts for the first time THEN the system SHALL check if SMS read permission is granted
2. IF SMS permission is not granted THEN the system SHALL request permission from the user with a clear explanation
3. WHEN the user denies SMS permission THEN the system SHALL continue to function with manual OTP entry only
4. WHEN the user grants SMS permission THEN the system SHALL enable automatic OTP reading functionality
5. IF the user previously denied permission THEN the system SHALL provide a way to enable it later through app settings

### Requirement 4: Platform-Specific Implementation

**User Story:** As a developer, I want the OTP reading feature to work correctly on both Android and iOS platforms, so that all users have a consistent experience.

#### Acceptance Criteria

1. WHEN the app runs on Android THEN the system SHALL use the SMS Retriever API or SMS User Consent API for OTP detection
2. WHEN the app runs on iOS THEN the system SHALL use appropriate iOS SMS reading mechanisms or fallback to manual entry
3. WHEN the platform does not support automatic SMS reading THEN the system SHALL gracefully degrade to manual OTP entry
4. WHEN implementing platform-specific code THEN the system SHALL handle platform differences without causing crashes or errors

### Requirement 5: Security and Privacy

**User Story:** As a user, I want my SMS messages to be handled securely, so that my privacy is protected and only relevant OTP messages are accessed.

#### Acceptance Criteria

1. WHEN reading SMS messages THEN the system SHALL only access messages from the sender "CP-ASKIT-T"
2. WHEN an OTP is extracted THEN the system SHALL NOT store the SMS message content permanently
3. WHEN the OTP screen is closed or verification is complete THEN the system SHALL stop listening for SMS messages
4. WHEN handling SMS data THEN the system SHALL comply with platform security guidelines and best practices
5. IF an error occurs during SMS reading THEN the system SHALL fail gracefully without exposing sensitive information

### Requirement 6: User Feedback and Error Handling

**User Story:** As a user, I want to receive appropriate feedback when automatic OTP reading succeeds or fails, so that I know what's happening and can take action if needed.

#### Acceptance Criteria

1. WHEN OTP is successfully auto-filled THEN the system SHALL provide subtle visual feedback (e.g., brief animation or indicator)
2. IF automatic OTP reading fails due to permission denial THEN the system SHALL display a helpful message explaining manual entry
3. WHEN an SMS is detected but OTP extraction fails THEN the system SHALL log the error for debugging without disrupting the user experience
4. IF the auto-filled OTP is incorrect THEN the system SHALL allow the user to manually correct it
5. WHEN the user manually enters OTP while auto-reading is active THEN the system SHALL prioritize user input over automatic detection
