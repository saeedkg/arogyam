import 'appointment_status.dart';

class Appointment {
  final int id;
  final String doctorName;
  final String doctorImage;
  final String specialization;
  final DateTime scheduledAt;
  final AppointmentStatus status;
  final String type; // instant, online, offline
  
  // Enhanced fields from API
  final double? consultationFee;
  final bool hasPrescription;
  final bool isFollowUpEligible;
  final String? consultationStatus;
  final int? doctorExperience;
  final List<String>? doctorQualifications;
  final bool canJoinNow;

  Appointment({
    required this.id,
    required this.doctorName,
    required this.doctorImage,
    required this.specialization,
    required this.scheduledAt,
    required this.status,
    required this.type,
    this.consultationFee,
    this.hasPrescription = false,
    this.isFollowUpEligible = false,
    this.consultationStatus,
    this.doctorExperience,
    this.doctorQualifications,
    this.canJoinNow = false,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final doctor = json['doctor'] ?? {};
    final user = doctor['user'] ?? {};

    // Parse qualifications
    List<String>? qualifications;
    if (doctor['qualifications'] != null && doctor['qualifications'] is List) {
      qualifications = (doctor['qualifications'] as List)
          .map((q) => q.toString())
          .toList();
    }

    // Parse consultation fee
    double? consultationFee;
    if (json['consultation_fee'] != null) {
      consultationFee = double.tryParse(json['consultation_fee'].toString());
    }

    // Parse doctor experience
    int? experience;
    if (doctor['experience'] != null) {
      experience = int.tryParse(doctor['experience'].toString());
    }

    return Appointment(
      id: json['id'] ?? 0,
      doctorName: user['name'] ?? 'Unknown Doctor',
      doctorImage: doctor['profile_photo_url'] ?? 'https://i.pravatar.cc/150?img=${doctor['id'] ?? 1}',
      specialization: _getPrimarySpecialization(doctor['specializations']),
      scheduledAt: DateTime.tryParse(json['scheduled_at'] ?? '') ?? DateTime.now(),
      status: AppointmentStatus.fromString(json['status'] ?? ''),
      type: json['type'] ?? 'online',
      consultationFee: consultationFee,
      hasPrescription: json['has_prescription'] ?? false,
      isFollowUpEligible: json['is_follow_up_eligible'] ?? false,
      consultationStatus: json['consultation_status'],
      doctorExperience: experience,
      doctorQualifications: qualifications,
      canJoinNow: json['can_join_now'] ?? false,
    );
  }

  static String _getPrimarySpecialization(dynamic specializations) {
    if (specializations == null || specializations is! List || specializations.isEmpty) {
      return 'General Medicine';
    }

    // Find primary specialization or use the first one
    for (var spec in specializations) {
      if (spec is Map<String, dynamic>) {
        final isPrimary = spec['pivot']?['is_primary'] == 1;
        if (isPrimary) {
          return spec['name'] ?? 'General Medicine';
        }
      }
    }

    // If no primary found, use the first specialization
    final firstSpec = specializations.first;
    if (firstSpec is Map<String, dynamic>) {
      return firstSpec['name'] ?? 'General Medicine';
    }

    return 'General Medicine';
  }
}
