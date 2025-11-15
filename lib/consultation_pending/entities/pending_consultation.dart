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
  
  // Waiting room metadata
  final bool awaitingDoctorAssignment;
  final int? queuePosition;
  final String? specializationId;
  final DateTime? requestedAt;

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
    this.awaitingDoctorAssignment = false,
    this.queuePosition,
    this.specializationId,
    this.requestedAt,
  });

  factory PendingConsultation.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>? ?? json;
    
    // The response can have 'appointment' nested or be the appointment itself
    final appointment = data['appointment'] as Map<String, dynamic>? ?? data;
    
    if (appointment['id'] == null) {
      throw Exception('Invalid response: missing appointment id');
    }
    
    final appointmentId = '${appointment['id']}';
    final status = appointment['status'] as String? ?? 'pending';
    final scheduledAtStr = appointment['scheduled_at'] as String?;
    if (scheduledAtStr == null) {
      throw Exception('Invalid response: missing scheduled_at');
    }
    final scheduledAt = DateTime.parse(scheduledAtStr);
    
    // Extract metadata for waiting room (could be at data level or appointment level)
    final metadata = data['metadata'] as Map<String, dynamic>? 
        ?? appointment['metadata'] as Map<String, dynamic>?;
    final awaitingDoctorAssignment = metadata?['awaiting_doctor_assignment'] as bool? ?? false;
    final queuePosition = metadata?['queue_position'] as int?;
    final specializationId = metadata?['specialization_id']?.toString();
    final requestedAtStr = metadata?['requested_at'] as String?;
    final requestedAt = requestedAtStr != null ? DateTime.tryParse(requestedAtStr) : null;
    
    // Doctor might be null if not assigned yet (at data level or appointment level)
    final doctor = data['doctor'] as Map<String, dynamic>? ?? appointment['doctor'] as Map<String, dynamic>?;
    
    // If no doctor, return a minimal pending consultation with metadata
    if (doctor == null) {
      return PendingConsultation(
        id: appointmentId,
        doctorName: '',
        doctorSpecialization: '',
        doctorImageUrl: 'https://i.pravatar.cc/150?img=10',
        scheduledAt: scheduledAt,
        status: status,
        canJoin: false,
        awaitingDoctorAssignment: awaitingDoctorAssignment,
        queuePosition: queuePosition,
        specializationId: specializationId,
        requestedAt: requestedAt,
      );
    }
    
    // Doctor is assigned - extract doctor info
    final user = doctor['user'] as Map<String, dynamic>?;
    final specs = (doctor['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specialization = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final imageUrl = user?['profile_image'] as String? ?? 'https://i.pravatar.cc/150?img=10';
    
    // Extract consultation and join details (at data level)
    final consultation = data['consultation'] as Map<String, dynamic>?;
    
    // user_join_details might be at consultation level or data level
    final consultationJoinDetails = consultation?['user_join_details'] as Map<String, dynamic>?;
    final dataLevelJoinDetails = data['user_join_details'] as Map<String, dynamic>?;
    final joinDetails = consultationJoinDetails ?? dataLevelJoinDetails;
    
    return PendingConsultation(
      id: appointmentId,
      doctorName: user?['name'] as String? ?? 'Doctor',
      doctorSpecialization: specialization,
      doctorImageUrl: imageUrl,
      scheduledAt: scheduledAt,
      status: status,
      consultationId: consultation != null ? '${consultation['id']}' : null,
      meetingId: consultation?['meeting_id'] as String?,
      meetingRoomName: consultation?['meeting_room_name'] as String?,
      authToken: joinDetails?['auth_token'] as String?,
      participantId: joinDetails?['participant_id'] as String?,
      participantRole: joinDetails?['role'] as String?,
      participantName: joinDetails?['name'] as String?,
      canJoin: consultation?['can_join'] as bool? ?? false,
      awaitingDoctorAssignment: false,
      queuePosition: null,
      specializationId: null,
      requestedAt: null,
    );
  }
  
  /// Check if doctor is assigned
  bool get hasDoctor => doctorName.isNotEmpty;
  
  /// Check if waiting for doctor assignment
  bool get isWaitingForDoctor => awaitingDoctorAssignment || (status == 'pending' && !hasDoctor);
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

