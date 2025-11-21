# Design Document

## Overview

This design introduces a `ConsultationTypeSelectionScreen` that acts as an intermediary step between `CareDiscoveryScreen` and `SpecialityDoctorsScreen`. The screen presents users with two consultation options: Clinic Appointment and Video Consultation. The design includes conditional navigation logic to skip this screen when users arrive from QuickActions on the dashboard, as those actions already imply a specific consultation type.

The implementation leverages the existing `ConsultationFlowManager` to manage navigation state and extends the current navigation pattern used in the care discovery flow.

## Architecture

### High-Level Flow

```
Dashboard QuickActions
├─ Hospital Appointment → CareDiscoveryScreen (consultationType: clinic) → SpecialityDoctorsScreen
├─ Video Consult → CareDiscoveryScreen (consultationType: video) → SpecialityDoctorsScreen
└─ Instant Consult → InstantConsultScreen (unchanged)

CareDiscoveryScreen (no pre-selected type)
└─ Select Speciality → ConsultationTypeSelectionScreen → SpecialityDoctorsScreen
```

### Navigation State Management

The consultation type will be managed through:
1. **ConsultationFlowManager** - Enhanced to accept and store optional `consultationType`
2. **Route Parameters** - Passed through navigation to maintain state
3. **CareDiscoveryScreen** - Receives optional `consultationType` parameter
4. **ConsultationTypeSelectionScreen** - New screen that captures user selection
5. **SpecialityDoctorsScreen** - Enhanced to receive optional `consultationType` parameter

## Components and Interfaces

### 1. ConsultationType Enum

```dart
enum ConsultationType {
  clinic,
  video;
  
  String get displayName {
    switch (this) {
      case ConsultationType.clinic:
        return 'Clinic Appointment';
      case ConsultationType.video:
        return 'Video Consultation';
    }
  }
  
  String get description {
    switch (this) {
      case ConsultationType.clinic:
        return 'Visit doctor at clinic';
      case ConsultationType.video:
        return 'Consult via video call';
    }
  }
  
  IconData get icon {
    switch (this) {
      case ConsultationType.clinic:
        return Icons.local_hospital_rounded;
      case ConsultationType.video:
        return Icons.videocam_rounded;
    }
  }
}
```

### 2. ConsultationTypeSelectionScreen

**Location:** `lib/care_discovery/ui/consultation_type_selection_screen.dart`

**Purpose:** Display consultation type options and navigate to SpecialityDoctorsScreen with selected type

**Key Properties:**
- `speciality` (String) - The selected speciality from CareDiscoveryScreen
- No controller needed - stateless screen with direct navigation

**UI Structure:**
```
AppBar
  ├─ Back Button
  ├─ Title: "Choose Consultation Type"
  └─ Subtitle: {speciality}

Body
  ├─ Header Text: "How would you like to consult?"
  ├─ Clinic Appointment Card
  │   ├─ Icon (Hospital)
  │   ├─ Title
  │   └─ Description
  └─ Video Consultation Card
      ├─ Icon (Video Camera)
      ├─ Title
      └─ Description
```

### 3. Enhanced ConsultationFlowManager

**Location:** `lib/_shared/consultation/consultation_flow_manager.dart`

**New/Modified Methods:**

```dart
class ConsultationFlowManager {
  ConsultationType? _preSelectedConsultationType;
  
  // Modified: Accept optional consultation type
  void startScheduledConsultation({ConsultationType? consultationType}) {
    _preSelectedConsultationType = consultationType;
    Get.to(() => CareDiscoveryScreen(
      entry: 'Find Care',
      preSelectedConsultationType: consultationType,
    ));
  }
  
  // New: Navigate from CareDiscovery to either selection screen or doctors
  void navigateFromCareDiscovery({
    required String speciality,
    ConsultationType? preSelectedType,
  }) {
    if (preSelectedType != null) {
      // Skip selection screen, go directly to doctors
      navigateToSpecialityDoctors(
        category: speciality,
        consultationType: preSelectedType,
      );
    } else {
      // Show consultation type selection screen
      Get.to(() => ConsultationTypeSelectionScreen(speciality: speciality));
    }
  }
  
  // Modified: Accept optional consultation type
  void navigateToSpecialityDoctors({
    required String category,
    ConsultationType? consultationType,
  }) {
    Get.to(() => SpecialityDoctorsScreen(
      category: category,
      consultationType: consultationType,
    ));
  }
  
  // New: Navigate from selection screen to doctors
  void navigateWithConsultationType({
    required String speciality,
    required ConsultationType consultationType,
  }) {
    navigateToSpecialityDoctors(
      category: speciality,
      consultationType: consultationType,
    );
  }
  
  // Clear state when needed
  void clearConsultationType() {
    _preSelectedConsultationType = null;
  }
}
```

### 4. Enhanced CareDiscoveryScreen

**Modified Properties:**
- Add optional `preSelectedConsultationType` parameter
- Pass this to navigation when speciality is selected

**Modified Navigation Logic:**
```dart
// In SpecializationGrid onTap
onTap: () {
  ConsultationFlowManager.instance.navigateFromCareDiscovery(
    speciality: s.name,
    preSelectedType: widget.preSelectedConsultationType,
  );
}
```

### 5. Enhanced SpecialityDoctorsScreen

**Modified Properties:**
- Add optional `consultationType` parameter
- Use this to filter or display doctors appropriately

**Usage:**
```dart
class SpecialityDoctorsScreen extends StatefulWidget {
  final String category;
  final ConsultationType? consultationType;
  
  const SpecialityDoctorsScreen({
    super.key,
    required this.category,
    this.consultationType,
  });
}
```

### 6. Updated QuickActions

**Modified onTap handlers:**

```dart
case QuickActionType.videoConsult:
  ConsultationFlowManager.instance.startScheduledConsultation(
    consultationType: ConsultationType.video,
  );
  break;
  
case QuickActionType.hospitalAppointment:
  ConsultationFlowManager.instance.startScheduledConsultation(
    consultationType: ConsultationType.clinic,
  );
  break;
```

## Data Models

### ConsultationType Enum
- **clinic** - Represents in-person clinic appointments
- **video** - Represents video consultation appointments

No additional data models required. The consultation type is passed as a simple enum through navigation parameters.

## UI/UX Design Specifications

### ConsultationTypeSelectionScreen Layout

**Colors:**
- Clinic Card: Light green background (`AppColors.successGreen.withOpacity(0.1)`)
- Video Card: Light blue background (`AppColors.infoBlue.withOpacity(0.1)`)
- Selected state: Slight elevation and border highlight

**Card Design:**
```
┌─────────────────────────────────┐
│  [Icon]                         │
│                                 │
│  Clinic Appointment             │
│  Visit doctor at clinic         │
│                                 │
└─────────────────────────────────┘
```

**Spacing:**
- Horizontal padding: 20px
- Vertical padding: 24px
- Card spacing: 16px between cards
- Card height: 160px
- Icon size: 48px
- Title font: 18px, bold
- Description font: 14px, regular

**Interaction:**
- Tap on card navigates immediately (no confirmation needed)
- Visual feedback: Scale animation (0.95) on tap
- Ripple effect on touch

## Error Handling

### Navigation Errors

1. **Missing Speciality Parameter**
   - Should not occur in normal flow
   - If it does, log error and navigate back to CareDiscoveryScreen

2. **Invalid ConsultationType**
   - Default to showing all doctors if type is invalid
   - Log warning for debugging

### State Management Errors

1. **Lost Navigation State**
   - If consultation type is lost during navigation, default to showing selection screen
   - User can still make selection manually

2. **Back Navigation**
   - Ensure consultation type state is cleared when navigating back to CareDiscoveryScreen
   - Prevent stale state from affecting future navigation

## Testing Strategy

### Unit Tests

1. **ConsultationType Enum Tests**
   - Test `displayName` returns correct strings
   - Test `description` returns correct strings
   - Test `icon` returns correct IconData

2. **ConsultationFlowManager Tests**
   - Test `startScheduledConsultation` with and without consultationType
   - Test `navigateFromCareDiscovery` with preSelectedType (should skip selection)
   - Test `navigateFromCareDiscovery` without preSelectedType (should show selection)
   - Test `clearConsultationType` clears state

### Widget Tests

1. **ConsultationTypeSelectionScreen Tests**
   - Test screen renders with correct speciality name
   - Test both consultation type cards are displayed
   - Test tapping clinic card navigates with correct type
   - Test tapping video card navigates with correct type
   - Test back button navigation

2. **CareDiscoveryScreen Tests**
   - Test navigation with preSelectedConsultationType skips selection
   - Test navigation without preSelectedConsultationType shows selection

3. **QuickActions Tests**
   - Test Hospital Appointment button passes clinic type
   - Test Video Consult button passes video type
   - Test Instant Consult button maintains existing behavior

### Integration Tests

1. **Full Flow Tests**
   - Test: Dashboard → Hospital Appointment → CareDiscovery → Select Speciality → SpecialityDoctors (skip selection)
   - Test: Dashboard → Video Consult → CareDiscovery → Select Speciality → SpecialityDoctors (skip selection)
   - Test: CareDiscovery → Select Speciality → ConsultationTypeSelection → Select Type → SpecialityDoctors
   - Test: Back navigation clears state correctly

2. **State Persistence Tests**
   - Test consultation type is maintained through navigation
   - Test consultation type is cleared on back navigation

## Implementation Notes

### File Structure

```
lib/
├── _shared/
│   └── consultation/
│       ├── consultation_flow_manager.dart (modified)
│       └── consultation_type.dart (new - enum)
├── care_discovery/
│   ├── ui/
│   │   ├── care_discovery_screen.dart (modified)
│   │   ├── consultation_type_selection_screen.dart (new)
│   │   └── components/
│   │       └── specialization_grid.dart (modified)
├── find_doctor/
│   └── ui/
│       └── speciality_doctors_screen.dart (modified)
└── landing/
    └── ui/
        └── components/
            └── dashboard_quick_action_view.dart (modified)
```

### Backward Compatibility

- `SpecialityDoctorsScreen` consultationType parameter is optional
- If not provided, screen behaves as before (shows all doctors)
- Existing direct navigation to SpecialityDoctorsScreen continues to work
- No breaking changes to existing APIs

### Performance Considerations

- ConsultationTypeSelectionScreen is lightweight (no API calls)
- Navigation state is minimal (single enum value)
- No impact on existing screen performance
- Conditional navigation logic is O(1)

## Future Enhancements

1. **Consultation Type Filtering**
   - Filter doctors in SpecialityDoctorsScreen based on consultation type
   - Show availability indicators for each type

2. **User Preferences**
   - Remember user's last selected consultation type
   - Offer to set default consultation type in settings

3. **Analytics**
   - Track which consultation type users prefer
   - Measure conversion rates for each type

4. **Dynamic Options**
   - Support additional consultation types (e.g., phone, chat)
   - Configure available types per speciality
