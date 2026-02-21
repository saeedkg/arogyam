# Notification Null Handling Fix

## Issue
The API returns `null` values for `sent_at`, `delivered_at`, and `clicked_at` fields when notifications are in "pending" status, but the entity model expected `sentAt` to be a required `DateTime` field, causing parsing errors.

## API Response Example
```json
{
  "id": 4,
  "notification_type": "test",
  "title": "Custom Test Title",
  "body": "Custom test message",
  "status": "pending",
  "sent_at": null,
  "delivered_at": null,
  "clicked_at": null,
  "device": {
    "id": 1,
    "device_name": "RMX3392",
    "device_type": "android"
  }
}
```

## Solution

### 1. Updated NotificationHistoryItem Entity
**File**: `lib/notification/entities/notification_history_item.dart`

Changed `sentAt` from required to nullable:

**Before**:
```dart
final DateTime sentAt;  // Required, would crash on null

NotificationHistoryItem({
  required this.sentAt,
  // ...
});

factory NotificationHistoryItem.fromJson(Map<String, dynamic> json) {
  return NotificationHistoryItem(
    sentAt: DateTime.parse(json['sent_at'] as String),  // Crashes if null
    // ...
  );
}
```

**After**:
```dart
final DateTime? sentAt;  // Nullable

NotificationHistoryItem({
  this.sentAt,  // Optional
  // ...
});

factory NotificationHistoryItem.fromJson(Map<String, dynamic> json) {
  return NotificationHistoryItem(
    sentAt: json['sent_at'] != null
        ? DateTime.parse(json['sent_at'] as String)
        : null,  // Handles null gracefully
    // ...
  );
}
```

### 2. Updated Time Formatting
**File**: `lib/notification/ui/notification_history_screen.dart`

Updated `_formatTime` method to handle nullable DateTime:

**Before**:
```dart
String _formatTime(DateTime dateTime) {
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  // ... formatting logic
}
```

**After**:
```dart
String _formatTime(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Pending';  // Show "Pending" for null dates
  }
  
  final now = DateTime.now();
  final difference = now.difference(dateTime);
  // ... formatting logic
}
```

## Notification Status Flow

### Pending Status
- `sent_at`: `null` → Shows "Pending"
- `delivered_at`: `null`
- `clicked_at`: `null`
- Status chip: Shows "Sent" or "Pending"

### Delivered Status
- `sent_at`: Has timestamp → Shows "2h ago"
- `delivered_at`: Has timestamp
- `clicked_at`: `null`
- Status chip: Shows "Delivered"

### Clicked Status
- `sent_at`: Has timestamp → Shows "2h ago"
- `delivered_at`: Has timestamp
- `clicked_at`: Has timestamp
- Status chip: Shows "Read"

## Benefits

1. **No More Crashes**: Handles null timestamps gracefully
2. **Better UX**: Shows "Pending" for notifications not yet sent
3. **Flexible**: Works with all notification statuses
4. **Type Safe**: Proper nullable types throughout

## Files Modified

1. `lib/notification/entities/notification_history_item.dart`
   - Made `sentAt` nullable
   - Updated `fromJson` to handle null
   - Updated `toJson` to handle null

2. `lib/notification/ui/notification_history_screen.dart`
   - Updated `_formatTime` to accept nullable DateTime
   - Returns "Pending" for null timestamps

## Testing Scenarios

- [x] Pending notifications (all dates null)
- [x] Sent notifications (sent_at has value)
- [x] Delivered notifications (sent_at and delivered_at have values)
- [x] Clicked notifications (all dates have values)
- [x] Mixed list of notifications with different statuses
- [x] No crashes on null values
- [x] Proper time formatting for all cases

## Status
✅ Complete and tested
✅ Handles all null cases gracefully
✅ No parsing errors
✅ Better user experience
