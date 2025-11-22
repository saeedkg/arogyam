/// Utility class for formatting dates and times
/// Handles UTC to local time conversion automatically
class DateTimeFormatter {
  DateTimeFormatter._(); // Private constructor to prevent instantiation

  /// Converts UTC DateTime to local DateTime
  static DateTime toLocal(DateTime utcDateTime) {
    return utcDateTime.toLocal();
  }

  /// Formats date as "Month Day, Year" (e.g., "January 15, 2024")
  /// Automatically converts UTC to local time
  static String formatDate(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${_getMonthName(localDateTime.month)} ${localDateTime.day}, ${localDateTime.year}';
  }

  /// Formats date as short format "MMM DD, YYYY" (e.g., "Jan 15, 2024")
  /// Automatically converts UTC to local time
  static String formatDateShort(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${_getMonthNameShort(localDateTime.month)} ${localDateTime.day}, ${localDateTime.year}';
  }

  /// Formats date as short format with 2-digit year "MMM DD, 'YY" (e.g., "Jan 15, '24")
  /// Automatically converts UTC to local time
  static String formatDateShortYear(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    final twoDigitYear = localDateTime.year % 100;
    return '${_getMonthNameShort(localDateTime.month)} ${localDateTime.day}, \'${twoDigitYear.toString().padLeft(2, '0')}';
  }

  /// Formats time as "HH:MM AM/PM" (e.g., "02:30 PM")
  /// Automatically converts UTC to local time
  static String formatTime(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    final hour = localDateTime.hour > 12
        ? localDateTime.hour - 12
        : (localDateTime.hour == 0 ? 12 : localDateTime.hour);
    final amPm = localDateTime.hour >= 12 ? 'PM' : 'AM';
    return '${_padZero(hour)}:${_padZero(localDateTime.minute)} $amPm';
  }

  /// Formats date and time as "Month Day, Year at HH:MM AM/PM"
  /// (e.g., "January 15, 2024 at 02:30 PM")
  /// Automatically converts UTC to local time
  static String formatDateTime(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${formatDate(localDateTime, isUtc: false)} at ${formatTime(localDateTime, isUtc: false)}';
  }

  /// Formats date and time as short format "MMM DD, YYYY • HH:MM AM/PM"
  /// (e.g., "Jan 15, 2024 • 02:30 PM")
  /// Automatically converts UTC to local time
  static String formatDateTimeShort(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${formatDateShort(localDateTime, isUtc: false)} • ${formatTime(localDateTime, isUtc: false)}';
  }

  /// Formats date as "Day, Month DD" (e.g., "Monday, January 15")
  /// Automatically converts UTC to local time
  static String formatDateWithDay(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${_getDayName(localDateTime.weekday)}, ${_getMonthName(localDateTime.month)} ${localDateTime.day}';
  }

  /// Formats date as "DD/MM/YYYY" (e.g., "15/01/2024")
  /// Automatically converts UTC to local time
  static String formatDateNumeric(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${_padZero(localDateTime.day)}/${_padZero(localDateTime.month)}/${localDateTime.year}';
  }

  /// Formats time in 24-hour format "HH:MM" (e.g., "14:30")
  /// Automatically converts UTC to local time
  static String formatTime24Hour(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${_padZero(localDateTime.hour)}:${_padZero(localDateTime.minute)}';
  }

  /// Returns relative time string (e.g., "Today", "Tomorrow", "Yesterday")
  /// Automatically converts UTC to local time
  static String formatRelativeDate(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final compareDate = DateTime(
      localDateTime.year,
      localDateTime.month,
      localDateTime.day,
    );

    final difference = compareDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == 1) {
      return 'Tomorrow';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > 1 && difference <= 7) {
      return _getDayName(localDateTime.weekday);
    } else {
      return formatDateShort(localDateTime, isUtc: false);
    }
  }

  /// Returns relative time with time (e.g., "Today at 02:30 PM")
  /// Automatically converts UTC to local time
  static String formatRelativeDateTime(DateTime dateTime, {bool isUtc = true}) {
    final localDateTime = isUtc ? dateTime.toLocal() : dateTime;
    return '${formatRelativeDate(localDateTime, isUtc: false)} at ${formatTime(localDateTime, isUtc: false)}';
  }

  // Helper methods

  static String _padZero(int value) {
    return value.toString().padLeft(2, '0');
  }

  static String _getMonthName(int month) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return months[month - 1];
  }

  static String _getMonthNameShort(int month) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return months[month - 1];
  }

  static String _getDayName(int weekday) {
    const days = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return days[weekday - 1];
  }
}
