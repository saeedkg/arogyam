# Doctor Detail Screen Phone Number Implementation

## Summary

Implemented dynamic phone number mapping in DoctorDetailInfoScreen with "Call Clinic" or "Call Hospital" button text based on the source of the phone number. Buttons only show when phone numbers are available.

## Changes Made

### 1. lib/find_doctor/entities/doctor_detail.dart

**Added Fields**:
- `clinicPhone` (nullable String) - Phone number from clinic or hospital
- `phoneSource` (nullable String) - Tracks if phone came from 'clinic' or 'hospital'

**Added Helper Methods**:
```dart
/// Check if phone number is available
bool get hasPhoneNumber {
  return clinicPhone != null && clinicPhone!.isNotEmpty;
}

/// Get call button text based on phone source
String get callButtonText {
  if (phoneSource == 'clinic') return 'Call Clinic';
  if (phoneSource == 'hospital') return 'Call Hospital';
  return 'Call';
}
```

### 2. lib/find_doctor/service/doctor_find_service.dart

**Updated `_mapToDoctorDetail` method**:
```dart
// Extract phone number from clinics or hospitals
String? clinicPhone;
String? phoneSource;

// First try to get phone from clinics
if (clinics != null && clinics.isNotEmpty) {
  final firstClinic = clinics.first;
  final contact = firstClinic['contact'] as Map<String, dynamic>?;
  clinicPhone = contact?['phone'] as String?;
  if (clinicPhone != null && clinicPhone.isNotEmpty) {
    phoneSource = 'clinic';
  }
}

// If no clinic phone, try hospitals
if (clinicPhone == null || clinicPhone.isEmpty) {
  if (hospitals != null && hospitals.isNotEmpty) {
    final firstHospital = hospitals.first;
    final contact = firstHospital['contact'] as Map<String, dynamic>?;
    clinicPhone = contact?['phone'] as String?;
    if (clinicPhone != null && clinicPhone.isNotEmpty) {
      phoneSource = 'hospital';
    }
  }
}

return DoctorDetail(
  ...
  clinicPhone: clinicPhone,
  phoneSource: phoneSource,
);
```

### 3. lib/find_doctor/ui/doctor_detail_info_screen.dart

**Updated Button Logic**:

1. **When from physical appointment (primary button)**:
   - Only shows if `doctorDetail.hasPhoneNumber` is true
   - Uses `doctorDetail.clinicPhone!` for actual phone number
   - Button text: `${doctorDetail.callButtonText} For Book Appointments`
   - Example: "Call Clinic For Book Appointments" or "Call Hospital For Book Appointments"

2. **When from video consultation (secondary button)**:
   - Only shows if `doctorDetail.hasPhoneNumber` is true
   - Uses `doctorDetail.clinicPhone!` for actual phone number
   - Button text: `doctorDetail.callButtonText`
   - Example: "Call Clinic" or "Call Hospital"

3. **Single offline consultation button**:
   - Only shows if `doctorDetail.hasPhoneNumber` is true
   - Uses `doctorDetail.clinicPhone!` for actual phone number
   - Button text: `doctorDetail.callButtonText`
   - If no phone number, returns `SizedBox.shrink()` (no button shown)

## Behavior

### With Phone Number from Clinic:
✅ Shows "Call Clinic For Book Appointments" (primary when from physical)
✅ Shows "Call Clinic" (secondary when from video)
✅ Uses actual clinic phone number from API

### With Phone Number from Hospital:
✅ Shows "Call Hospital For Book Appointments" (primary when from physical)
✅ Shows "Call Hospital" (secondary when from video)
✅ Uses actual hospital phone number from API

### Without Phone Number:
✅ No call button shown for physical appointments
✅ Only video consultation button shows (if available)
✅ Clean UI without disabled/placeholder buttons

## API Response Example

```json
{
  "success": true,
  "data": {
    "id": 4,
    "user": {"name": "dr sachin"},
    "profile_photo_url": "https://arogyam.focus-its.com/storage/profile-photos/x0Qsxp41lCKw8df676qtiVbrJyGqA4YummtwVbFa.jpg",
    "clinics": [
      {
        "id": 2,
        "name": "Family Clinic 2",
        "contact": {
          "phone": "+1234567302",
          "email": "clinic2@example.com"
        }
      }
    ],
    "hospitals": []
  }
}
```

## Testing Status

- ✅ No compilation errors
- ✅ Entity updated with phone fields and helper methods
- ✅ Service extracts phone from clinics (priority) or hospitals (fallback)
- ✅ UI uses actual phone numbers and dynamic button text
- ✅ Buttons only show when phone numbers exist
- ⏳ Ready for testing with real API data

## Notes

- Phone extraction priority: Clinics first, then hospitals
- Only the first clinic or hospital phone number is used
- Button text is context-aware based on phone source
- Consistent implementation with DoctorCard component
- Clean UX - no buttons shown when phone numbers unavailable
