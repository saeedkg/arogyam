# Doctor Profile Photo URL Fix

## Summary

Updated DoctorDetailBottomSheet, DoctorDetailInfoScreen, and doctor listing (SpecialityDoctorsScreen with DoctorCard) to use the actual `profile_photo_url` from the API instead of hardcoded placeholder images.

## API Field

The API endpoints return:
```json
{
  "data": {
    "profile_photo_url": "https://arogyam.focus-its.com/storage/profile-photos/x0Qsxp41lCKw8df676qtiVbrJyGqA4YummtwVbFa.jpg",
    ...
  }
}
```

## Files Modified

### 1. lib/doctor_detail/entities/doctor_detail_data.dart
**Changed**: Updated `fromJson` factory method to use `profile_photo_url` from API

**Before**:
```dart
imageUrl: 'https://i.pravatar.cc/150?img=22',
```

**After**:
```dart
imageUrl: doctor['profile_photo_url'] as String? ?? '',
```

**Note**: Empty string fallback allows UI to show its own placeholder icon

### 2. lib/find_doctor/service/doctor_find_service.dart
**Changed**: Updated `_mapToDoctorDetail` method to use `profile_photo_url` from API

**Before**:
```dart
imageUrl: 'https://i.pravatar.cc/150?img=22',
```

**After**:
```dart
// Get profile photo URL from API
final profilePhotoUrl = json['profile_photo_url'] as String? ?? '';

return DoctorDetail(
  ...
  imageUrl: profilePhotoUrl,
  ...
);
```

**Note**: Empty string fallback allows UI to show its own placeholder icon

### 3. lib/find_doctor/service/doctors_get_detail_service.dart
**Changed**: Updated `_mapToListItem` method to use `profile_photo_url` from API for doctor listings

**Before**:
```dart
imageUrl: 'https://i.pravatar.cc/150?img=10',
```

**After**:
```dart
// Get profile photo URL from API
final profilePhotoUrl = json['profile_photo_url'] as String? ?? '';

return DoctorListItem(
  ...
  imageUrl: profilePhotoUrl,
  ...
);
```

**Note**: Empty string fallback allows UI to show its own placeholder icon

### 4. lib/instant_consultation/entities/detailed_instant_doctor.dart
**Changed**: Updated `fromJson` factory method to use `profile_photo_url` from API for instant consultation doctors

**Before**:
```dart
imageUrl: 'https://i.pravatar.cc/150?img=10',
```

**After**:
```dart
// Get profile photo URL from API
final profilePhotoUrl = json['profile_photo_url'] as String? ?? '';

return DetailedInstantDoctor(
  ...
  imageUrl: profilePhotoUrl,
  ...
);
```

**Note**: Empty string fallback allows UI to show its own placeholder icon

## Affected Screens

1. **DoctorDetailBottomSheet** (`lib/doctor_detail/ui/doctor_detail_bottom_sheet.dart`)
   - Shows doctor profile photo in bottom sheet
   - Now displays actual doctor photo from API

2. **DoctorDetailInfoScreen** (`lib/find_doctor/ui/doctor_detail_info_screen.dart`)
   - Shows doctor profile photo in full detail screen
   - Now displays actual doctor photo from API

3. **SpecialityDoctorsScreen** (`lib/find_doctor/ui/speciality_doctors_screen.dart`)
   - Shows doctor list with DoctorCard components
   - Each card now displays actual doctor photo from API

4. **DoctorCard** (`lib/find_doctor/ui/components/doctor_card.dart`)
   - Displays doctor profile photo in list items
   - Now shows actual doctor photos from API

5. **DoctorsSelectionBottomSheet** (`lib/instant_consultation/ui/doctors_selection_bottom_sheet.dart`)
   - Shows doctor list for instant consultation
   - Now displays actual doctor photos from API

## Fallback Behavior

All implementations use empty string as fallback if:
- The API doesn't return `profile_photo_url`
- The field is null or empty
- Fallback value: `''` (empty string)

This allows the UI components to show their own placeholder icons/images instead of using generic avatar URLs.

**UI Error Handling:**
Each screen already has `errorBuilder` in `Image.network()` that displays:
- A container with grey background
- A person icon placeholder
- This provides a consistent, professional fallback across all screens

## Benefits

✅ Displays actual doctor profile photos from the server across all screens
✅ Maintains fallback for missing images
✅ Consistent with API data structure
✅ No breaking changes (graceful degradation)
✅ No compilation errors
✅ Works for both detail views and list views

## Testing

- ✅ No compilation errors
- ⏳ Test with actual API to verify profile photos display correctly in all screens
- ⏳ Test fallback behavior when profile_photo_url is null
- ⏳ Test error handling when image fails to load
- ⏳ Test doctor listing in SpecialityDoctorsScreen
- ⏳ Test DoctorCard component with real photos

## Notes

- The `profile_photo_url` field is at the doctor level in the API response
- All screens use the same `imageUrl` field from their respective entity classes
- Error handling for failed image loads is already implemented in all screens
- Doctor listing API and detail API both return the same `profile_photo_url` field
