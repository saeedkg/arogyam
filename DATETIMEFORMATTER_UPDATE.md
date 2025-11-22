# DateTimeFormatter Update - formatDateShortYear()

## New Method Added

### `formatDateShortYear(DateTime dateTime, {bool isUtc = true})`

Formats date with a 2-digit year in the format "MMM DD, 'YY"

## Usage

```dart
import 'package:arogyam/_shared/utils/date_time_formatter.dart';

// Example with UTC DateTime
final utcDateTime = DateTime.utc(2024, 1, 15, 14, 30);

// Format with 2-digit year
final formatted = DateTimeFormatter.formatDateShortYear(utcDateTime);
print(formatted); // Output: "Jan 15, '24"

// Compare with full year format
final fullYear = DateTimeFormatter.formatDateShort(utcDateTime);
print(fullYear); // Output: "Jan 15, 2024"
```

## Examples

```dart
// 2024 → '24
DateTimeFormatter.formatDateShortYear(DateTime(2024, 3, 15));
// Output: "Mar 15, '24"

// 2023 → '23
DateTimeFormatter.formatDateShortYear(DateTime(2023, 12, 25));
// Output: "Dec 25, '23"

// 2000 → '00
DateTimeFormatter.formatDateShortYear(DateTime(2000, 1, 1));
// Output: "Jan 1, '00"

// 2009 → '09
DateTimeFormatter.formatDateShortYear(DateTime(2009, 7, 4));
// Output: "Jul 4, '09"
```

## Implementation Details

```dart
static String formatDateShortYear(DateTime dateTime, {bool isUtc = true}) {
  final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
  final twoDigitYear = localDateTime.year % 100;
  return '${_getMonthNameShort(localDateTime.month)} ${localDateTime.day}, \'${twoDigitYear.toString().padLeft(2, '0')}';
}
```

### Key Features:
- ✅ Extracts last 2 digits of year using modulo operator (`year % 100`)
- ✅ Pads with leading zero for years 00-09 (e.g., '09 not '9)
- ✅ Includes apostrophe before year ('24)
- ✅ Automatic UTC to local conversion (default)
- ✅ Optional `isUtc` parameter for local DateTime

## Use Cases

### 1. Space-Constrained UI
Perfect for mobile UI where space is limited:
```dart
// Health Records Card
Text(DateTimeFormatter.formatDateShortYear(record.date))
// "Jan 15, '24" - More compact than "Jan 15, 2024"
```

### 2. Appointment Lists
```dart
// Appointment Card
Text(DateTimeFormatter.formatDateShortYear(appointment.date))
// "Mar 20, '24"
```

### 3. Timeline Views
```dart
// Timeline Entry
Text(DateTimeFormatter.formatDateShortYear(event.timestamp))
// "Dec 31, '23"
```

### 4. Chat Messages
```dart
// Message Timestamp
Text(DateTimeFormatter.formatDateShortYear(message.sentAt))
// "Feb 14, '24"
```

## Comparison with Other Methods

| Method | Output | Use Case |
|--------|--------|----------|
| `formatDate()` | "January 15, 2024" | Full, formal dates |
| `formatDateShort()` | "Jan 15, 2024" | Abbreviated month, full year |
| `formatDateShortYear()` | "Jan 15, '24" | **Compact, space-saving** |
| `formatDateNumeric()` | "15/01/2024" | International format |

## Benefits

### Before (Custom Implementation):
```dart
String _formatDate(DateTime d) => 
  '${["Jan","Feb","Mar",...][d.month-1]} ${d.day}, \'${d.year%100}';
```

### After (Using DateTimeFormatter):
```dart
final formatted = DateTimeFormatter.formatDateShortYear(dateTime);
```

**Advantages:**
- ✅ Centralized formatting logic
- ✅ Automatic UTC to local conversion
- ✅ Consistent across the app
- ✅ Proper zero-padding for years 00-09
- ✅ Easy to maintain

## Updated Files

1. `lib/_shared/utils/date_time_formatter.dart` - Added new method
2. `lib/_shared/utils/date_time_formatter_example.dart` - Added usage example
3. `DATE_TIME_FORMATTER_GUIDE.md` - Updated documentation

## Testing

```dart
void testFormatDateShortYear() {
  // Test normal year
  final date1 = DateTime(2024, 1, 15);
  assert(DateTimeFormatter.formatDateShortYear(date1, isUtc: false) == "Jan 15, '24");
  
  // Test year with leading zero
  final date2 = DateTime(2009, 3, 5);
  assert(DateTimeFormatter.formatDateShortYear(date2, isUtc: false) == "Mar 5, '09");
  
  // Test year 2000
  final date3 = DateTime(2000, 12, 31);
  assert(DateTimeFormatter.formatDateShortYear(date3, isUtc: false) == "Dec 31, '00");
  
  // Test UTC conversion
  final utcDate = DateTime.utc(2024, 6, 15, 14, 30);
  final formatted = DateTimeFormatter.formatDateShortYear(utcDate);
  // Output depends on local timezone
  
  print('All tests passed!');
}
```

## Migration Guide

If you're using custom date formatting like in health_records_screen.dart:

### Before:
```dart
String _formatDate(DateTime d) => 
  '${["Jan","Feb","Mar","Apr","May","Jun","Jul","Aug","Sep","Oct","Nov","Dec"][d.month-1]} ${d.day}, \'${d.year%100}';
```

### After:
```dart
// Just use the utility
DateTimeFormatter.formatDateShortYear(d, isUtc: false)
```

## Real-World Example

### Health Records Screen:
```dart
// Before (custom method):
Text(_formatDate(record.date))

// After (using DateTimeFormatter):
Text(DateTimeFormatter.formatDateShortYear(record.date, isUtc: false))
```

Both produce: "Jan 15, '24"

## Notes

1. **Year Padding**: Years 2000-2009 are formatted as '00-'09 (with leading zero)
2. **Apostrophe**: Always includes apostrophe before year ('24)
3. **UTC Handling**: By default assumes UTC and converts to local
4. **Local DateTime**: Use `isUtc: false` if DateTime is already local

## Complete Method List

Now DateTimeFormatter has 12 methods:

1. `formatDate()` - Full date with full year
2. `formatDateShort()` - Short month with full year
3. **`formatDateShortYear()`** - **Short month with 2-digit year** ⭐ NEW
4. `formatTime()` - 12-hour time format
5. `formatTime24Hour()` - 24-hour time format
6. `formatDateTime()` - Full date and time
7. `formatDateTimeShort()` - Short date and time
8. `formatDateWithDay()` - Date with day name
9. `formatDateNumeric()` - Numeric date format
10. `formatRelativeDate()` - Relative dates (Today, Tomorrow, etc.)
11. `formatRelativeDateTime()` - Relative date with time
12. `toLocal()` - UTC to local conversion
