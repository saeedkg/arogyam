import 'appointment_status.dart';

class Appointment {
  final int id;
  final String doctorName;
  final String doctorImage;
  final String specialization;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final String type; // instant, online, offline

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorImage,
    required this.specialization,
    required this.scheduledAt,
    required this.status,
    required this.type,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] ?? {};
    final user = doctor['user'] ?? {};

    return Appointment(
      id: json['id'] ?? 0,
      doctorName: user['name'] ?? 'Unknown Doctor',
      doctorImage: 'https://i.pravatar.cc/150?img=${doctor['id'] ?? 1}',
      specialization: (doctor['qualifications'] != null &&
          doctor['qualifications'] is List)
          ? (doctor['qualifications'] as List).join(', ')
          : '',
      scheduledAt:
      DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      status: AppointmentStatus.fromString(json['status'] ?? ''),
      type: json['type'] ?? 'online',
    );
  }
}
