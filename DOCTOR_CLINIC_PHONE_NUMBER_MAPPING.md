# Doctor Clinic/Hospital Phone Number Mapping

## Summary

Added phone number mapping from clinics/hospitals in the doctor listing API. The "Call Clinic" or "Call Hospital" button will only show if a phone number is available.

## API Response Structure

```json
{
  "data": {
    "doctors": [
      {
        "id": 4,
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
        "hospitals": [
          {
            "id": 4,
            "name": "Arogyam hospital",
            "contact": {
              "phone": null,
              "email": null
            }
          }
        ]
      }
    ]
  }
}
```

## Changes Made

### 1. lib/find_doctor/entities/doctor_list_item.dart

**Added**:
- `clinicPhone` field (nullable String) to store phone number
- `phoneSource` field (nullable String) to track if phone came from 'clinic' or 'hospital'
- `hasPhoneNumber` getter to check if phone is available
- `callButtonText` getter to return appropriate button text based on source

```dart
class DoctorListItem {
  ...
  final String? clinicPhone; // Phone number from clinic or hospital
  final String? phoneSource; // 'clinic' or 'hospital' - indicates where phone came from
  
  const DoctorListItem({
    ...
    this.clinicPhone,
    this.phoneSource,
  });
  
  // Helper method to check if phone number is available
  bool get hasPhoneNumber {
    return clinicPhone != null && clinicPhone!.isNotEmpty;
  }
  
  // Helper method to get call button text
  String get callButtonText {
    if (phoneSource == 'clinic') return 'Call Clinic';
    if (phoneSource == 'hospital') return 'Call Hospital';
    return 'Call';
  }
}
```

### 2. lib/find_doctor/service/doctors_get_detail_service.dart

**Updated `_mapToListItem` method**:

```dart
// Extract phone number from clinics or hospitals
String? clinicPhone;
String? phoneSource;

// First try to get phone from clinics
final clinics = json['clinics'] as List<dynamic>? ?? [];
if (clinics.isNotEmpty) {
  final firstClinic = clinics.first as Map<String, dynamic>;
  final contact = firstClinic['contact'] as Map<String, dynamic>?;
  clinicPhone = contact?['phone'] as String?;
  if (clinicPhone != null && clinicPhone.isNotEmpty) {
    phoneSource = 'clinic';
  }
}

// If no clinic phone, try hospitals
if (clinicPhone == null || clinicPhone.isEmpty) {
  final hospitals = json['hospitals'] as List<dynamic>? ?? [];
  if (hospitals.isNotEmpty) {
    final firstHospital = hospitals.first as Map<String, dynamic>;
    final contact = firstHospital['contact'] as Map<String, dynamic>?;
    clinicPhone = contact?['phone'] as String?;
    if (clinicPhone != null && clinicPhone.isNotEmpty) {
      phoneSource = 'hospital';
    }
  }
}

return DoctorListItem(
  ...
  clinicPhone: clinicPhone,
  phoneSource: phoneSource,
);
```

## Logic

1. **Priority**: Clinics are checked first, then hospitals
2. **Extraction**: Only the phone number from `contact.phone` is mapped
3. **Source Tracking**: `phoneSource` is set to 'clinic' or 'hospital' based on where phone was found
4. **Fallback**: If no phone number is found in either clinics or hospitals, both `clinicPhone` and `phoneSource` will be `null`
5. **Helper Methods**: 
   - Use `doctor.hasPhoneNumber` to check if phone is available before showing call button
   - Use `doctor.callButtonText` to get appropriate button text ('Call Clinic' or 'Call Hospital')

## Usage in UI

```dart
// In DoctorCard or any doctor list UI
if (doctor.hasPhoneNumber) {
  ElevatedButton(
    onPressed: () => _makePhoneCall(doctor.clinicPhone!),
    child: Text(doctor.callButtonText), // Shows "Call Clinic" or "Call Hospital"
  );
}
```

## Benefits

✅ Only maps relevant phone number field (not all clinic/hospital data)
✅ Checks both clinics and hospitals for phone number
✅ Provides helper method to easily check if phone is available
✅ Null-safe implementation
✅ No compilation errors
✅ Minimal data mapping (efficient)

## UI Implementation

### lib/find_doctor/ui/components/doctor_card.dart

**Updated button visibility logic**:

```dart
// For video consultations: Show "Book Consult" if doctor has instant/online consultation
// For physical appointments: Show "Call Clinic/Hospital" ONLY if phone number exists
if ((appointmentType != AppointmentFilterType.physical && doctor.hasInstantOrOnlineConsultation) || 
    (appointmentType == AppointmentFilterType.physical && doctor.hasPhoneNumber))
  SizedBox(
    height: 36,
    child: ElevatedButton.icon(
      onPressed: () {
        // If physical appointment, make phone call
        if (appointmentType == AppointmentFilterType.physical && doctor.hasPhoneNumber) {
          _makePhoneCall(doctor.clinicPhone!);
        } else {
          // Navigate to booking for video consult
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DoctorBookingScreen(
                doctorId: doctor.id,
              ),
            ),
          );
        }
      },
      ...
      label: Text(
        appointmentType == AppointmentFilterType.physical 
            ? doctor.callButtonText  // "Call Clinic" or "Call Hospital"
            : 'Book Consult',
        ...
      ),
    ),
  ),
```

**Key Changes**:
- **Physical appointments**: Button ONLY shows if `doctor.hasPhoneNumber` is true
- **Video consultations**: Button shows if `doctor.hasInstantOrOnlineConsultation` is true
- Uses actual `doctor.clinicPhone!` instead of hardcoded number
- Button text dynamically shows "Call Clinic" or "Call Hospital" based on `doctor.callButtonText`
- **No phone number = No button** for physical appointments
- Maintains existing "Book Consult" button for instant/online consultations

## Testing

- ✅ No compilation errors
- ✅ UI implementation complete
- ⏳ Test with doctors that have clinic phone numbers
- ⏳ Test with doctors that have hospital phone numbers
- ⏳ Test with doctors that have no phone numbers
- ⏳ Test with doctors that have both clinics and hospitals
- ⏳ Verify "Call Clinic" button only shows when phone is available

## Notes

- Only the first clinic or hospital phone number is used
- If a doctor has multiple clinics/hospitals, only the first one with a phone number is mapped
- The `hasPhoneNumber` getter provides a clean way to conditionally show call buttons in the UI
- The `callButtonText` getter automatically returns "Call Clinic" or "Call Hospital" based on source
- For physical appointments without phone numbers, no button will be shown
- For video consultations, the "Book Consult" button always shows if doctor has instant/online consultation types
- Button text is dynamic and context-aware based on where the phone number originated
