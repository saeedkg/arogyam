# Doctor Card Consultation Types Update

## Overview
Updated the DoctorCard component to support consultation types and show a "Book Now" button for instant and online consultations. Also moved the rating from bottom to top, replacing the favorite icon.

## Changes Made

### 1. DoctorListItem Entity Updates

#### Added New Field:
- **consultationTypes**: `List<String>` - Array of consultation types (`["offline","instant","online"]`)
- **hasInstantOrOnlineConsultation**: Helper getter to check if instant or online consultation is available

#### Updated Constructor:
```dart
const DoctorListItem({
  // ... existing fields
  this.consultationTypes = const [],
});
```

### 2. DoctorsApiService Updates

#### Enhanced Data Mapping:
- Added mapping for `consultation_types` from API response
- Extracts consultation types array and converts to List<String>

#### Updated _mapToListItem Method:
```dart
// Map consultation types from API
final consultationTypesRaw = json['consultation_types'] as List<dynamic>? ?? [];
final consultationTypes = consultationTypesRaw.map((e) => e.toString()).toList();
```

### 3. DoctorCard UI Updates

#### Layout Changes:
1. **Moved Rating to Top**: Replaced favorite icon with rating display next to doctor name
2. **Added Book Now Button**: Shows when `hasInstantOrOnlineConsultation` is true
3. **Improved Bottom Layout**: Better spacing and alignment for availability status and button

#### Visual Enhancements:
- **Rating Display**: Compact star icon + rating number next to doctor name
- **Book Now Button**: Professional blue button with proper styling
- **Responsive Layout**: Button only appears when instant/online consultation is available

## UI Behavior

### Rating Display:
- **Location**: Top right, next to doctor name
- **Style**: Small star icon + rating number (e.g., "4.5")
- **Size**: Compact 12px font, 16px star icon

### Book Now Button:
- **Condition**: Only shows if `consultationTypes` contains "instant" or "online"
- **Style**: Blue elevated button with white text
- **Size**: 32px height, compact padding
- **Action**: Navigates to doctor booking screen

### Layout Structure:
```
┌─────────────────────────────────────┐
│ [Photo] Dr. Name            ⭐ 4.5  │
│         Specialization              │
│         Qualification               │
│         Exp: 5+ yrs    Fee: ₹500    │
├─────────────────────────────────────┤
│ 🟢 Online  📅 Available    [Book Now]│
└─────────────────────────────────────┘
```

## API Integration

### Expected API Response:
```json
{
  "consultation_types": ["offline", "instant", "online"],
  // ... other doctor fields
}
```

### Consultation Types:
- **"offline"**: In-person consultation only
- **"instant"**: Immediate online consultation available
- **"online"**: Scheduled online consultation available

## Technical Implementation

### Helper Method:
```dart
bool get hasInstantOrOnlineConsultation {
  return consultationTypes.contains('instant') || consultationTypes.contains('online');
}
```

### Conditional Button Rendering:
```dart
if (doctor.hasInstantOrOnlineConsultation)
  Container(
    height: 32,
    child: ElevatedButton(
      onPressed: () => AppNavigation.toDoctorBooking(doctor.id),
      child: const Text('Book Now'),
    ),
  ),
```

## Files Modified
1. `lib/find_doctor/entities/doctor_list_item.dart` - Added consultation types field
2. `lib/find_doctor/service/doctors_get_detail_service.dart` - Updated API mapping
3. `lib/find_doctor/ui/components/doctor_card.dart` - Updated UI layout and logic

## Benefits
1. **Enhanced UX**: Clear indication of available consultation types
2. **Quick Booking**: Direct "Book Now" button for instant/online consultations
3. **Better Information Hierarchy**: Rating moved to more prominent position
4. **Responsive Design**: Button only appears when relevant
5. **Professional Appearance**: Clean, modern button styling

## Backward Compatibility
- All existing functionality preserved
- Default empty array for consultation types ensures no breaking changes
- Favorite icon functionality can be re-added if needed in future