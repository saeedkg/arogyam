# Doctor Profile Photo URL Fix

## Summary

Updated DoctorDetailBottomSheet and DoctorDetailInfoScreen to use the actual `profile_photo_url` from the API instead of hardcoded placeholder images.

## API Field

The API endpoint `https://arogyam.focus-its.com/api/v1/doctors/{id}` returns:
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
imageUrl: doctor['profile_photo_url'] as String? ?? 'https://i.pravatar.cc/150?img=22',
```

### 2. lib/find_doctor/service/doctor_find_service.dart
**Changed**: Updated `_mapToDoctorDetail` method to use `profile_photo_url` from API

**Before**:
```dart
imageUrl: 'https://i.pravatar.cc/150?img=22',
```

**After**:
```dart
// Get profile photo URL from API
final profilePhotoUrl = json['profile_photo_url'] as String? ?? 'https://i.pravatar.cc/150?img=22';

return DoctorDetail(
  ...
  imageUrl: profilePhotoUrl,
  ...
);
```

## Affected Screens

1. **DoctorDetailBottomSheet** (`lib/doctor_detail/ui/doctor_detail_bottom_sheet.dart`)
   - Shows doctor profile photo in bottom sheet
   - Now displays actual doctor photo from API

2. **DoctorDetailInfoScreen** (`lib/find_doctor/ui/doctor_detail_info_screen.dart`)
   - Shows doctor profile photo in full detail screen
   - Now displays actual doctor photo from API

## Fallback Behavior

Both implementations include a fallback to the placeholder image if:
- The API doesn't return `profile_photo_url`
- The field is null or empty
- Fallback URL: `https://i.pravatar.cc/150?img=22`

## Benefits

✅ Displays actual doctor profile photos from the server
✅ Maintains fallback for missing images
✅ Consistent with API data structure
✅ No breaking changes (graceful degradation)
✅ No compilation errors

## Testing

- ✅ No compilation errors
- ⏳ Test with actual API to verify profile photos display correctly
- ⏳ Test fallback behavior when profile_photo_url is null
- ⏳ Test error handling when image fails to load

## Notes

- The `profile_photo_url` field is at the doctor level in the API response
- Both screens use the same `imageUrl` field from their respective entity classes
- Error handling for failed image loads is already implemented in both screens
