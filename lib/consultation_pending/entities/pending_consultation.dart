class PendingConsultation {
  final String id;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorImageUrl;
  final DateTime scheduledAt;
  final String status;
  final String totalAmount;

  PendingConsultation({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorImageUrl,
    required this.scheduledAt,
    required this.status,
    required this.totalAmount,
  });

  factory PendingConsultation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final doctor = data['doctor'] as Map<String, dynamic>;
    final user = doctor['user'] as Map<String, dynamic>;
    final specs = (doctor['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specialization = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    return PendingConsultation(
      id: '${data['id']}',
      doctorName: user['name'] as String? ?? 'Doctor',
      doctorSpecialization: specialization,
      doctorImageUrl: 'https://i.pravatar.cc/150?img=10',
      scheduledAt: DateTime.parse(data['scheduled_at'] as String),
      status: data['status'] as String? ?? 'pending',
      totalAmount: data['total_amount'] as String? ?? '0.00',
    );
  }
}

class VideoCallJoinResponse {
  final String meetingId;
  final String roomName;
  final String authToken;
  final String participantId;
  final String role;

  VideoCallJoinResponse({
    required this.meetingId,
    required this.roomName,
    required this.authToken,
    required this.participantId,
    required this.role,
  });

  factory VideoCallJoinResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return VideoCallJoinResponse(
      meetingId: data['meeting_id'] as String? ?? '',
      roomName: data['room_name'] as String? ?? '',
      authToken: data['auth_token'] as String? ?? '',
      participantId: data['participant_id'] as String? ?? '',
      role: data['role'] as String? ?? '',
    );
  }
}

