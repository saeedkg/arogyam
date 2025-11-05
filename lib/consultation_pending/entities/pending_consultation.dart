class PendingConsultation {
  final String id;
  final String doctorName;
  final String doctorSpecialization;
  final String doctorImageUrl;
  final DateTime scheduledAt;
  final String status;
  final String? consultationId;
  final String? meetingId;
  final String? meetingRoomName;
  
  // Join details
  final String? authToken;
  final String? participantId;
  final String? participantRole;
  final String? participantName;
  final bool canJoin;

  PendingConsultation({
    required this.id,
    required this.doctorName,
    required this.doctorSpecialization,
    required this.doctorImageUrl,
    required this.scheduledAt,
    required this.status,
    this.consultationId,
    this.meetingId,
    this.meetingRoomName,
    this.authToken,
    this.participantId,
    this.participantRole,
    this.participantName,
    this.canJoin = false,
  });

  factory PendingConsultation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final appointment = data['appointment'] as Map<String, dynamic>;
    final doctor = appointment['doctor'] as Map<String, dynamic>;
    final user = doctor['user'] as Map<String, dynamic>;
    final specs = (doctor['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specialization = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    
    // Extract consultation and join details
    final consultation = data['consultation'] as Map<String, dynamic>?;
    final joinDetails = consultation?['user_join_details'] as Map<String, dynamic>?;
    
    return PendingConsultation(
      id: '${appointment['id']}',
      doctorName: user['name'] as String? ?? 'Doctor',
      doctorSpecialization: specialization,
      doctorImageUrl: 'https://i.pravatar.cc/150?img=10',
      scheduledAt: DateTime.parse(appointment['scheduled_at'] as String),
      status: appointment['status'] as String? ?? 'pending',
      consultationId: consultation != null ? '${consultation['id']}' : null,
      meetingId: consultation?['meeting_id'] as String?,
      meetingRoomName: consultation?['meeting_room_name'] as String?,
      authToken: joinDetails?['auth_token'] as String?,
      participantId: joinDetails?['participant_id'] as String?,
      participantRole: joinDetails?['role'] as String?,
      participantName: joinDetails?['name'] as String?,
      canJoin: joinDetails?['can_join'] as bool? ?? false,
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

