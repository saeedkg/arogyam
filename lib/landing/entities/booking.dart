class BookingItem {
  final String id;
  final String doctorName;
  final String specialization;
  final String clinic;
  final String imageUrl;
  final DateTime dateTime;
  final String status; // upcoming, completed, canceled

  const BookingItem({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.clinic,
    required this.imageUrl,
    required this.dateTime,
    required this.status,
  });
}

