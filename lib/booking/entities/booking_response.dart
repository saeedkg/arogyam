class BookingResponse {
  final String id;
  final String doctorName;
  final DateTime scheduledAt;
  final String status;
  final String totalAmount;

  BookingResponse({
    required this.id,
    required this.doctorName,
    required this.scheduledAt,
    required this.status,
    required this.totalAmount,
  });

  factory BookingResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final doctor = data['doctor'] as Map<String, dynamic>;
    final user = doctor['user'] as Map<String, dynamic>;
    return BookingResponse(
      id: '${data['id']}',
      doctorName: user['name'] as String? ?? 'Doctor',
      scheduledAt: DateTime.parse(data['scheduled_at'] as String),
      status: data['status'] as String? ?? 'pending',
      totalAmount: data['total_amount'] as String? ?? '0.00',
    );
  }
}

