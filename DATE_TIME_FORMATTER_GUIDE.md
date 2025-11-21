# DateTimeFormatter Utility Guide

## Overview
A comprehensive utility class for formatting dates and times in Flutter applications. Automatically handles UTC to local time conversion.

## Location
`lib/_shared/utils/date_time_formatter.dart`

## Features
✅ Automatic UTC to local time conversion
✅ Multiple date format options
✅ Multiple time format options
✅ Relative date formatting (Today, Tomorrow, Yesterday)
✅ 12-hour and 24-hour time formats
✅ Customizable UTC/local handling
✅ Zero dependencies (uses only Dart core)

## Installation
No installation needed - just import the file:
```dart
import 'package:arogyam/_shared/utils/date_time_formatter.dart';
```

## API Reference

### Date Formatting Methods

#### 1. `formatDate(DateTime dateTime, {bool isUtc = true})`
Formats date as "Month Day, Year"
```dart
DateTimeFormatter.formatDate(utcDateTime);
// Output: "January 15, 2024"
```

#### 2. `formatDateShort(DateTime dateTime, {bool isUtc = true})`
Formats date as "MMM DD, YYYY"
```dart
DateTimeFormatter.formatDateShort(utcDateTime);
// Output: "Jan 15, 2024"
```

#### 3. `formatDateWithDay(DateTime dateTime, {bool isUtc = true})`
Formats date with day name
```dart
DateTimeFormatter.formatDateWithDay(utcDateTime);
// Output: "Monday, January 15"
```

#### 4. `formatDateNumeric(DateTime dateTime, {bool isUtc = true})`
Formats date as "DD/MM/YYYY"
```dart
DateTimeFormatter.formatDateNumeric(utcDateTime);
// Output: "15/01/2024"
```

### Time Formatting Methods

#### 5. `formatTime(DateTime dateTime, {bool isUtc = true})`
Formats time as "HH:MM AM/PM" (12-hour format)
```dart
DateTimeFormatter.formatTime(utcDateTime);
// Output: "02:30 PM"
```

#### 6. `formatTime24Hour(DateTime dateTime, {bool isUtc = true})`
Formats time as "HH:MM" (24-hour format)
```dart
DateTimeFormatter.formatTime24Hour(utcDateTime);
// Output: "14:30"
```

### Combined Date & Time Methods

#### 7. `formatDateTime(DateTime dateTime, {bool isUtc = true})`
Formats as "Month Day, Year at HH:MM AM/PM"
```dart
DateTimeFormatter.formatDateTime(utcDateTime);
// Output: "January 15, 2024 at 02:30 PM"
```

#### 8. `formatDateTimeShort(DateTime dateTime, {bool isUtc = true})`
Formats as "MMM DD, YYYY • HH:MM AM/PM"
```dart
DateTimeFormatter.formatDateTimeShort(utcDateTime);
// Output: "Jan 15, 2024 • 02:30 PM"
```

### Relative Date Methods

#### 9. `formatRelativeDate(DateTime dateTime, {bool isUtc = true})`
Returns relative date string
```dart
DateTimeFormatter.formatRelativeDate(todayUtc);
// Output: "Today"

DateTimeFormatter.formatRelativeDate(tomorrowUtc);
// Output: "Tomorrow"

DateTimeFormatter.formatRelativeDate(yesterdayUtc);
// Output: "Yesterday"

DateTimeFormatter.formatRelativeDate(nextWeekUtc);
// Output: "Monday" (or day name if within 7 days)

DateTimeFormatter.formatRelativeDate(nextMonthUtc);
// Output: "Feb 15, 2024" (if beyond 7 days)
```

#### 10. `formatRelativeDateTime(DateTime dateTime, {bool isUtc = true})`
Returns relative date with time
```dart
DateTimeFormatter.formatRelativeDateTime(todayUtc);
// Output: "Today at 02:30 PM"
```

### Utility Methods

#### 11. `toLocal(DateTime utcDateTime)`
Explicitly converts UTC to local time
```dart
final localDateTime = DateTimeFormatter.toLocal(utcDateTime);
```

## Usage Examples

### Basic Usage (UTC DateTime from API)
```dart
// Assume API returns UTC DateTime
final utcDateTime = DateTime.parse('2024-01-15T14:30:00Z');

// Format date
final date = DateTimeFormatter.formatDate(utcDateTime);
print(date); // "January 15, 2024" (in local time)

// Format time
final time = DateTimeFormatter.formatTime(utcDateTime);
print(time); // "02:30 PM" (in local time)

// Format both
final dateTime = DateTimeFormatter.formatDateTime(utcDateTime);
print(dateTime); // "January 15, 2024 at 02:30 PM" (in local time)
```

### Using with Local DateTime
```dart
// If you already have local DateTime
final localDateTime = DateTime.now();

// Set isUtc to false to skip conversion
final formatted = DateTimeFormatter.formatDateTime(
  localDateTime,
  isUtc: false,
);
```

### In a Widget
```dart
class AppointmentCard extends StatelessWidget {
  final DateTime appointmentDateTimeUtc;

  const AppointmentCard({
    super.key,
    required this.appointmentDateTimeUtc,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(
          DateTimeFormatter.formatDate(appointmentDateTimeUtc),
        ),
        subtitle: Text(
          DateTimeFormatter.formatTime(appointmentDateTimeUtc),
        ),
        trailing: Text(
          DateTimeFormatter.formatRelativeDate(appointmentDateTimeUtc),
        ),
      ),
    );
  }
}
```

### Replacing Existing Code
```dart
// OLD CODE:
String _formatDate(DateTime dt) {
  return '${_month(dt.month)} ${dt.day}, ${dt.year}';
}

String _formatTime(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return '${_pad(hour)}:${_pad(dt.minute)} $amPm';
}

// NEW CODE (cleaner and handles UTC):
final date = DateTimeFormatter.formatDate(utcDateTime);
final time = DateTimeFormatter.formatTime(utcDateTime);
```

### Common Use Cases

#### Appointment Display
```dart
// Show appointment date and time
Text(DateTimeFormatter.formatDateTime(appointment.dateTimeUtc))
// Output: "January 15, 2024 at 02:30 PM"
```

#### Upcoming Appointments
```dart
// Show relative date for upcoming appointments
Text(DateTimeFormatter.formatRelativeDateTime(appointment.dateTimeUtc))
// Output: "Today at 02:30 PM" or "Tomorrow at 10:00 AM"
```

#### Appointment History
```dart
// Show short format for history
Text(DateTimeFormatter.formatDateTimeShort(appointment.dateTimeUtc))
// Output: "Jan 15, 2024 • 02:30 PM"
```

#### Calendar View
```dart
// Show date with day name
Text(DateTimeFormatter.formatDateWithDay(appointment.dateTimeUtc))
// Output: "Monday, January 15"
```

## Parameters

### `isUtc` Parameter
All methods accept an optional `isUtc` parameter (default: `true`)

- **`isUtc: true`** (default): Assumes input is UTC and converts to local time
- **`isUtc: false`**: Assumes input is already in local time, no conversion

```dart
// UTC DateTime (from API)
DateTimeFormatter.formatDate(utcDateTime); // Converts to local
DateTimeFormatter.formatDate(utcDateTime, isUtc: true); // Same as above

// Local DateTime (already local)
DateTimeFormatter.formatDate(localDateTime, isUtc: false); // No conversion
```

## Benefits

### Before (Manual Formatting)
```dart
String _formatDate(DateTime dt) {
  return '${_month(dt.month)} ${dt.day}, ${dt.year}';
}

String _formatTime(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return '${_pad(hour)}:${_pad(dt.minute)} $amPm';
}

String _month(int m) {
  const months = ['Jan', 'Feb', 'Mar', ...];
  return months[m - 1];
}

String _pad(int n) => n.toString().padLeft(2, '0');

// Issues:
// ❌ No UTC to local conversion
// ❌ Code duplication across files
// ❌ Hard to maintain
// ❌ No relative date support
```

### After (Using DateTimeFormatter)
```dart
// Simple, clean, and handles UTC conversion
final date = DateTimeFormatter.formatDate(utcDateTime);
final time = DateTimeFormatter.formatTime(utcDateTime);
final relative = DateTimeFormatter.formatRelativeDate(utcDateTime);

// Benefits:
// ✅ Automatic UTC to local conversion
// ✅ Centralized formatting logic
// ✅ Easy to maintain
// ✅ Multiple format options
// ✅ Relative date support
```

## Testing

```dart
void testDateTimeFormatter() {
  // Test UTC conversion
  final utc = DateTime.utc(2024, 1, 15, 14, 30);
  
  print('Date: ${DateTimeFormatter.formatDate(utc)}');
  print('Time: ${DateTimeFormatter.formatTime(utc)}');
  print('DateTime: ${DateTimeFormatter.formatDateTime(utc)}');
  print('Relative: ${DateTimeFormatter.formatRelativeDate(utc)}');
  
  // Test with current time
  final now = DateTime.now().toUtc();
  print('Now: ${DateTimeFormatter.formatRelativeDateTime(now)}');
}
```

## Notes

1. **UTC Assumption**: By default, all methods assume input is UTC and convert to local time
2. **Timezone Handling**: Uses Dart's built-in `toLocal()` method for conversion
3. **No External Dependencies**: Pure Dart implementation
4. **Immutable**: All methods are static and don't modify input
5. **Null Safety**: Fully null-safe implementation

## Migration Guide

If you have existing date/time formatting code, here's how to migrate:

1. Import the utility:
   ```dart
   import 'package:arogyam/_shared/utils/date_time_formatter.dart';
   ```

2. Replace manual formatting:
   ```dart
   // Before
   final formatted = '${_month(dt.month)} ${dt.day}, ${dt.year}';
   
   // After
   final formatted = DateTimeFormatter.formatDate(dt);
   ```

3. Remove helper methods:
   - Delete `_formatDate`, `_formatTime`, `_month`, `_pad`, etc.
   - Use `DateTimeFormatter` methods instead

4. Update UTC handling:
   - If your DateTime is UTC, use default behavior
   - If your DateTime is local, add `isUtc: false`

## Support

For issues or questions, refer to the example file:
`lib/_shared/utils/date_time_formatter_example.dart`
