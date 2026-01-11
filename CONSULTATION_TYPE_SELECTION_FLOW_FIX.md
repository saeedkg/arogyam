# Consultation Type Selection Flow Fix

## Issue
The consultation type selection screen was being skipped when using `BookingFlowEntry.specializationFilter`, even when no appointment type was pre-selected. This meant users couldn't choose between Video Consultation and Clinic Visit.

## Root Cause
The `_startFromSpecializationFilter` method was calling `_navigateToSpecialityDoctors` directly without checking if an appointment type was provided:

```dart
// WRONG - Always goes directly to doctors, skipping consultation type selection
Future<void> _startFromSpecializationFilter(String? selectedSpecialization, AppointmentType? appointmentType) async {
  if (selectedSpecialization != null) {
    _navigateToSpecialityDoctors(selectedSpecialization, appointmentType); // ❌ Always calls this
  } else {
    _startFromDashboard(appointmentType);
  }
}
```

## Solution
Added proper logic to check if appointment type is provided:

```dart
// CORRECT - Checks if appointment type is provided
Future<void> _startFromSpecializationFilter(String? selectedSpecialization, AppointmentType? appointmentType) async {
  if (selectedSpecialization != null) {
    if (appointmentType != null) {
      // Appointment type already selected, go directly to doctors
      _navigateToSpecialityDoctors(selectedSpecialization, appointmentType);
    } else {
      // Need to select consultation type first
      _navigateToConsultationTypeSelection(selectedSpecialization);
    }
  } else {
    _startFromDashboard(appointmentType);
  }
}
```

## Flow Comparison

### Before (Wrong Flow):
Dashboard Category → SpecialityDoctorsScreen (with null appointmentType) ❌

### After (Correct Flow):
Dashboard Category → ConsultationTypeSelectionScreen → SpecialityDoctorsScreen ✅

## Different Entry Point Behaviors

### 1. Dashboard Categories (No Pre-selected Type)
```dart
BookingFlowManager.instance.startBookingFlow(
  entry: BookingFlowEntry.specializationFilter,
  selectedSpecialization: 'Cardiology',
  // appointmentType: null (not provided)
);
```
**Flow:** Cardiology → ConsultationTypeSelection → SpecialityDoctors

### 2. Quick Actions (Pre-selected Type)
```dart
BookingFlowManager.instance.startBookingFlow(
  entry: BookingFlowEntry.quickAction,
  appointmentType: AppointmentType.video,
);
```
**Flow:** CareDiscovery → SpecialityDoctors (skips consultation type selection)

### 3. Search Results with Pre-selected Type
```dart
BookingFlowManager.instance.startBookingFlow(
  entry: BookingFlowEntry.specializationFilter,
  selectedSpecialization: 'Cardiology',
  appointmentType: AppointmentType.video,
);
```
**Flow:** SpecialityDoctors (skips consultation type selection)

## Benefits

1. ✅ **Proper Flow Logic**: Consultation type selection is shown when needed
2. ✅ **User Choice**: Users can choose between Video and Clinic appointments
3. ✅ **Efficiency**: Still skips consultation type selection when type is pre-selected
4. ✅ **Consistency**: All entry points now follow the correct flow logic

## Testing Scenarios

- ✅ Dashboard category click → Shows consultation type selection
- ✅ Quick action (Video) → Skips consultation type selection
- ✅ Quick action (Clinic) → Skips consultation type selection  
- ✅ Search result with no type → Shows consultation type selection
- ✅ Search result with pre-selected type → Skips consultation type selection

The consultation type selection screen is now properly integrated into the booking flow!