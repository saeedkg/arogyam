// Example usage of DateTimeFormatter utility class

import 'date_time_formatter.dart';

void exampleUsage() {
  // Assume you receive a UTC DateTime from API
  final utcDateTime = DateTime.utc(2024, 1, 15, 14, 30); // 2:30 PM UTC

  // 1. Format date: "January 15, 2024"
  final formattedDate = DateTimeFormatter.formatDate(utcDateTime);
  print(formattedDate); // Output: January 15, 2024 (in local time)

  // 2. Format date (short): "Jan 15, 2024"
  final formattedDateShort = DateTimeFormatter.formatDateShort(utcDateTime);
  print(formattedDateShort); // Output: Jan 15, 2024 (in local time)

  // 3. Format time: "02:30 PM"
  final formattedTime = DateTimeFormatter.formatTime(utcDateTime);
  print(formattedTime); // Output: 02:30 PM (in local time)

  // 4. Format date and time: "January 15, 2024 at 02:30 PM"
  final formattedDateTime = DateTimeFormatter.formatDateTime(utcDateTime);
  print(formattedDateTime); // Output: January 15, 2024 at 02:30 PM (in local time)

  // 5. Format date and time (short): "Jan 15, 2024 • 02:30 PM"
  final formattedDateTimeShort =
      DateTimeFormatter.formatDateTimeShort(utcDateTime);
  print(formattedDateTimeShort); // Output: Jan 15, 2024 • 02:30 PM (in local time)

  // 6. Format with day name: "Monday, January 15"
  final formattedWithDay = DateTimeFormatter.formatDateWithDay(utcDateTime);
  print(formattedWithDay); // Output: Monday, January 15 (in local time)

  // 7. Format numeric: "15/01/2024"
  final formattedNumeric = DateTimeFormatter.formatDateNumeric(utcDateTime);
  print(formattedNumeric); // Output: 15/01/2024 (in local time)

  // 8. Format 24-hour time: "14:30"
  final formatted24Hour = DateTimeFormatter.formatTime24Hour(utcDateTime);
  print(formatted24Hour); // Output: 14:30 (in local time)

  // 9. Format relative date: "Today", "Tomorrow", "Yesterday", etc.
  final today = DateTime.now().toUtc();
  final relativeDate = DateTimeFormatter.formatRelativeDate(today);
  print(relativeDate); // Output: Today

  // 10. Format relative date with time: "Today at 02:30 PM"
  final relativeDateTime = DateTimeFormatter.formatRelativeDateTime(today);
  print(relativeDateTime); // Output: Today at 02:30 PM (in local time)

  // 11. If you already have local DateTime (not UTC), set isUtc to false
  final localDateTime = DateTime.now();
  final formattedLocal =
      DateTimeFormatter.formatDateTime(localDateTime, isUtc: false);
  print(formattedLocal);

  // 12. Convert UTC to local explicitly
  final localConverted = DateTimeFormatter.toLocal(utcDateTime);
  print(localConverted); // DateTime object in local timezone
}

// Example in a widget
/*
class AppointmentCard extends StatelessWidget {
  final DateTime appointmentDateTimeUtc;

  const AppointmentCard({required this.appointmentDateTimeUtc});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Text(DateTimeFormatter.formatDate(appointmentDateTimeUtc)),
          Text(DateTimeFormatter.formatTime(appointmentDateTimeUtc)),
          // Or combined:
          Text(DateTimeFormatter.formatDateTime(appointmentDateTimeUtc)),
        ],
      ),
    );
  }
}
*/

// Example replacing your existing code
/*
// OLD CODE:
String _formatDate(DateTime dt) {
  return '${_month(dt.month)} ${dt.day}, ${dt.year}';
}

String _formatTime(DateTime dt) {
  final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
  final amPm = dt.hour >= 12 ? 'PM' : 'AM';
  return '${_pad(hour)}:${_pad(dt.minute)} $amPm';
}

// NEW CODE (assuming dt is UTC):
final formattedDate = DateTimeFormatter.formatDate(dt);
final formattedTime = DateTimeFormatter.formatTime(dt);
// Or combined:
final formattedDateTime = DateTimeFormatter.formatDateTime(dt);
*/
