# Implementation Plan

- [x] 1. Create ConsultationType enum and core types


  - Create `lib/_shared/consultation/consultation_type.dart` with ConsultationType enum
  - Add displayName, description, and icon getters to the enum
  - Export the enum from the consultation module
  - _Requirements: 1.2, 1.3, 1.4, 4.5, 4.6_




- [ ] 2. Create ConsultationTypeSelectionScreen UI
  - [ ] 2.1 Create the screen file and basic structure
    - Create `lib/care_discovery/ui/consultation_type_selection_screen.dart`
    - Implement StatelessWidget with speciality parameter


    - Add AppBar with back button and title showing speciality
    - _Requirements: 1.1, 1.5, 1.6, 4.1_
  
  - [x] 2.2 Implement consultation type selection cards

    - Create two selection cards for Clinic and Video consultation types
    - Add icons, titles, and descriptions to each card


    - Implement visual styling with colors and shadows
    - Add tap handlers that navigate to SpecialityDoctorsScreen with selected type
    - _Requirements: 1.2, 1.3, 1.4, 4.2, 4.3, 4.4_



- [ ] 3. Update ConsultationFlowManager for type management
  - [x] 3.1 Add consultation type state management

    - Add private `_preSelectedConsultationType` field
    - Modify `startScheduledConsultation` to accept optional consultationType parameter
    - Add `clearConsultationType` method


    - _Requirements: 3.1, 3.2, 3.4_
  
  - [x] 3.2 Implement conditional navigation logic


    - Create `navigateFromCareDiscovery` method with conditional logic
    - Update `navigateToSpecialityDoctors` to accept optional consultationType
    - Create `navigateWithConsultationType` method for selection screen


    - _Requirements: 2.3, 3.1, 3.2_

- [ ] 4. Update CareDiscoveryScreen for consultation type flow
  - [x] 4.1 Add preSelectedConsultationType parameter


    - Add optional `preSelectedConsultationType` parameter to CareDiscoveryScreen



    - Pass parameter to SpecializationGrid component
    - _Requirements: 2.1, 2.2, 3.4_
  
  - [ ] 4.2 Update SpecializationGrid navigation
    - Modify onTap handler to use ConsultationFlowManager.navigateFromCareDiscovery
    - Pass preSelectedConsultationType to navigation method
    - _Requirements: 2.3, 3.2_

- [ ] 5. Update SpecialityDoctorsScreen to receive consultation type
  - Add optional `consultationType` parameter to SpecialityDoctorsScreen
  - Update constructor and widget properties
  - Ensure backward compatibility when consultationType is null
  - _Requirements: 3.2, 3.5, 5.2, 5.3_

- [ ] 6. Update QuickActions to pass consultation types
  - Modify Hospital Appointment QuickAction to pass ConsultationType.clinic
  - Modify Video Consult QuickAction to pass ConsultationType.video
  - Ensure Instant Consult QuickAction remains unchanged
  - _Requirements: 2.1, 2.2, 2.4, 2.5_

- [ ] 7. Update routing configuration
  - Add ConsultationTypeSelectionScreen route to AppRoutes if using named routes
  - Ensure all navigation paths are properly configured
  - _Requirements: 5.5_

- [ ]* 8. Add unit tests for ConsultationType enum
  - Test displayName getter returns correct values
  - Test description getter returns correct values
  - Test icon getter returns correct IconData
  - _Requirements: 1.2, 1.3, 1.4_

- [ ]* 9. Add widget tests for ConsultationTypeSelectionScreen
  - Test screen renders with correct speciality name
  - Test both consultation type cards are displayed
  - Test tapping clinic card navigates correctly
  - Test tapping video card navigates correctly
  - Test back button navigation
  - _Requirements: 1.1, 1.2, 1.3, 1.4, 1.5, 1.6_

- [ ]* 10. Add integration tests for complete flows
  - Test QuickAction → CareDiscovery → Speciality → Doctors (skip selection)
  - Test CareDiscovery → Speciality → Selection → Doctors (show selection)
  - Test back navigation clears state
  - _Requirements: 2.1, 2.2, 2.3, 3.3, 5.1_
