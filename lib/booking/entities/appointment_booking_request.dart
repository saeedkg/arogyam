class AppointmentBookingRequest {
  final String doctorId;
  final DateTime scheduledAt;
  final String type;
  final String paymentMode;
  final String paymentMethod;
  final String symptoms;
  final String notes;
  final String? patientId; // family_member_id, if any

  AppointmentBookingRequest({
    required this.doctorId,
    required this.scheduledAt,
    required this.type,
    required this.paymentMode,
    required this.paymentMethod,
    required this.symptoms,
    required this.notes,
    this.patientId,
  });

  Map<String, dynamic> toJson() {
    return {
      'doctor_id': doctorId,
      'scheduled_at': scheduledAt.toUtc().toIso8601String(),
      'type': type,
      'payment_mode': paymentMode,
      'payment_method': paymentMethod,
      'symptoms': symptoms,
      'notes': notes,
      if (patientId != null) 'patient_id': patientId,  // family_member_id
    };
  }
}
