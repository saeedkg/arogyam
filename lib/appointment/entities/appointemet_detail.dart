class AppointmentDetail {
  final int id;
  final String doctorName;
  final String doctorEmail;
  final String bio;
  final String qualifications;
  final DateTime scheduledAt;
  final String status;

  AppointmentDetail({
    required this.id,
    required this.doctorName,
    required this.doctorEmail,
    required this.bio,
    required this.qualifications,
    required this.scheduledAt,
    required this.status,
  });

  factory AppointmentDetail.fromJson(Map<String, dynamic> json) {
    final appointmentJson = json['data']['appointment'];

    final doctor = appointmentJson['doctor'] ?? {};
    final user = appointmentJson['user'] ?? {};
    return AppointmentDetail(
      id: json['id'] ?? 0,
      doctorName: user['name'] ?? '',
      doctorEmail: user['email'] ?? '',
      bio: doctor['bio'] ?? '',
      qualifications: (doctor['qualifications'] != null &&
          doctor['qualifications'] is List)
          ? (doctor['qualifications'] as List).join(', ')
          : '',
      scheduledAt:
      DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      status: json['status'] ?? '',
    );
  }
}
