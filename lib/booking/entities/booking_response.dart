class BookingResponse {
  final String id;
  final String? doctorName;
  final DateTime scheduledAt;
  final String status;
  final dynamic totalAmount;

  BookingResponse({
    required this.id,
    this.doctorName,
    required this.scheduledAt,
    required this.status,
    required this.totalAmount,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>?;
    if (data == null) {
      throw Exception('Invalid response: missing data');
    }

    final appointmentId = '${data['id']}';
    final status = data['status'] as String? ?? 'pending';
    final scheduledAtStr = data['scheduled_at'] as String?;
    if (scheduledAtStr == null) {
      throw Exception('Invalid response: missing scheduled_at');
    }
    final scheduledAt = DateTime.parse(scheduledAtStr);
    final totalAmount = data['total_amount'] ?? '0.00';

    // Doctor might be null if not assigned yet
    final doctor = data['doctor'] as Map<String, dynamic>?;
    // final doctorName = doctor != null
    //     ? (doctor['user'] as Map<String, dynamic>?)?['name'] as String?
    //     : null;

    final doctorName = (doctor?['user']?['name'])?.toString();


    return BookingResponse(
      id: appointmentId,
      doctorName: doctorName,
      scheduledAt: scheduledAt,
      status: status,
      totalAmount: totalAmount,
    );
  }
}

