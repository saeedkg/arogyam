# Doctor Booking Patient Selection Update

## Overview
Updated the DoctorBookingScreen to remove the patient selection section from the main UI and instead show a patient selection bottom sheet when the user taps "Proceed to Payment". Once a patient is chosen, the payment flow continues.

## Changes Made

### 1. Updated DoctorBookingScreen (`lib/booking/ui/doctor_booking_screen.dart`)

#### Removed Components:
- **Patient Selection Section**: Removed `_PatientSelection` component from main UI
- **selectedFamilyMemberId Variable**: No longer needed as state variable
- **_PatientSelection Widget**: Completely removed the component class

#### Added Functionality:

##### New Import:
```dart
import '../../family_member/ui/family_member_screen.dart';
```

##### New Method: `_showPatientSelectionAndProceed()`
```dart
Future<void> _showPatientSelectionAndProceed() async {
  // Show patient selection bottom sheet
  final selectedPatientId = await Get.bottomSheet<String>(
    const FamilyMembersBottomSheet(),
    isScrollControlled: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
    ),
  );

  // If a patient was selected, proceed with payment
  if (selectedPatientId != null) {
    final d = c.detail.value!;
    final selectedSlot = c.selectedSlot.value!;
    final scheduledAt = selectedSlot.dateTimeString;

    // Initiate Razorpay payment
    await bookingController.initiatePayment(
      doctorId: d.id,
      scheduledAt: scheduledAt,
      familyMemberId: selectedPatientId,
      patientNotes: "First consultation",
    );
  }
}
```

#### Updated Button Behavior:
- **Before**: Button directly initiated payment with pre-selected patient
- **After**: Button shows patient selection bottom sheet first, then proceeds with payment

### 2. Updated UI Layout

#### Removed Sections:
```dart
// REMOVED: Patient selection section
_PatientSelection(
  selectedId: selectedFamilyMemberId,
  onTap: () {
    // TODO: Open FamilyMembers flow and set selectedFamilyMemberId
  },
),
```

#### Simplified Layout:
```dart
children: [
  _DoctorProfileCard(d: d),
  const SizedBox(height: 24),
  _AvailabilitySection(controller: c, doctor: d),
  const SizedBox(height: 24),
  _PaymentDetailsSection(bookingController: bookingController),
  const SizedBox(height: 100), // space before bottom button
],
```

## User Experience Flow

### Before:
1. User sees doctor details
2. User selects date/time
3. User selects patient from UI section
4. User taps "Proceed to Payment"
5. Payment flow starts

### After:
1. User sees doctor details
2. User selects date/time
3. User taps "Proceed to Payment"
4. **Patient selection bottom sheet appears**
5. User selects patient from bottom sheet
6. Payment flow starts automatically

## Benefits

### 1. **Cleaner UI**
- Removed clutter from main screen
- More focus on doctor details and scheduling
- Better use of screen space

### 2. **Better UX Flow**
- Patient selection happens at the right moment (just before payment)
- Users don't need to think about patient selection until necessary
- Consistent with other apps' checkout flows

### 3. **Improved Interaction**
- Bottom sheet provides better patient selection experience
- Full family member list with proper selection UI
- Can add new family members if needed

### 4. **Simplified State Management**
- No need to track selected patient in main screen state
- Patient selection is handled in the payment flow
- Cleaner component structure

## Technical Implementation

### Bottom Sheet Integration:
- Uses existing `FamilyMembersBottomSheet` component
- Returns selected patient ID when user chooses
- Handles cancellation gracefully (no payment if no selection)

### Payment Flow:
- Patient selection result is passed directly to payment initiation
- No intermediate state storage needed
- Seamless transition from selection to payment

### Error Handling:
- If user cancels patient selection, payment doesn't proceed
- Existing payment error handling remains unchanged
- No additional error states needed

## UI Components Affected

### Removed:
- `_PatientSelection` widget class
- Patient selection section from main layout
- `selectedFamilyMemberId` state variable

### Modified:
- "Proceed to Payment" button behavior
- Main screen layout structure
- Payment initiation flow

### Added:
- `_showPatientSelectionAndProceed()` method
- Bottom sheet integration
- Conditional payment flow

## Testing Checklist

- [ ] Doctor booking screen loads without patient selection section
- [ ] Date and time selection works correctly
- [ ] "Proceed to Payment" button shows patient selection bottom sheet
- [ ] Patient selection bottom sheet displays family members
- [ ] Selecting a patient proceeds to payment
- [ ] Canceling patient selection doesn't start payment
- [ ] Payment flow works with selected patient
- [ ] Error handling works correctly
- [ ] UI layout looks clean without patient section

## Backward Compatibility

- All existing functionality preserved
- Payment APIs unchanged
- Family member selection logic unchanged
- Only UI flow and timing modified