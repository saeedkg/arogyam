class DashboardData {
  final AppointmentCounts appointmentCounts;
  final List<ConsultationToJoin> consultationsToJoin;
  final int totalDoctors;
  final List<RecentConsultation> recentConsultations;
  final List<UpcomingAppointment> upcomingAppointments;
  final int familyMembersCount;
  final List<FollowUpChatSummary> followUpChats;

  DashboardData({
    required this.appointmentCounts,
    required this.consultationsToJoin,
    required this.totalDoctors,
    required this.recentConsultations,
    required this.upcomingAppointments,
    required this.familyMembersCount,
    required this.followUpChats,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return DashboardData(
      appointmentCounts: AppointmentCounts.fromJson(data['appointment_counts'] as Map<String, dynamic>),
      consultationsToJoin: (data['consultations_to_join'] as List<dynamic>)
          .map((e) => ConsultationToJoin.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalDoctors: data['total_doctors'] as int,
      recentConsultations: (data['recent_consultations'] as List<dynamic>)
          .map((e) => RecentConsultation.fromJson(e as Map<String, dynamic>))
          .toList(),
      upcomingAppointments: (data['upcoming_appointments'] as List<dynamic>)
          .map((e) => UpcomingAppointment.fromJson(e as Map<String, dynamic>))
          .toList(),
      familyMembersCount: data['family_members_count'] as int,
      followUpChats: (data['follow_up_chats'] as List<dynamic>?)
          ?.map((e) => FollowUpChatSummary.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
    );
  }
}

class AppointmentCounts {
  final int completed;
  final int pending;
  final int instant;
  final int scheduled;

  AppointmentCounts({
    required this.completed,
    required this.pending,
    required this.instant,
    required this.scheduled,
  });

  factory AppointmentCounts.fromJson(Map<String, dynamic> json) {
    return AppointmentCounts(
      completed: json['completed'] as int,
      pending: json['pending'] as int,
      instant: json['instant'] as int,
      scheduled: json['scheduled'] as int,
    );
  }
}

class ConsultationToJoin {
  final int id;
  final String type;
  final String status;
  final DateTime scheduledAt;
  final String doctorName;
  final String? doctorImage;
  final String doctorSlug;

  ConsultationToJoin({
    required this.id,
    required this.type,
    required this.status,
    required this.scheduledAt,
    required this.doctorName,
    this.doctorImage,
    required this.doctorSlug,
  });

  factory ConsultationToJoin.fromJson(Map<String, dynamic> json) {
    return ConsultationToJoin(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at'] as String? ?? DateTime.now().toIso8601String()),
      doctorName: json['doctor_name'] as String? ?? '',
      doctorImage: json['doctor_image'] as String?,
      doctorSlug: json['doctor_slug'] as String? ?? '',
    );
  }
}

class RecentConsultation {
  final int id;
  final String type;
  final String status;
  final DateTime scheduledAt;
  final String doctorName;
  final String? doctorImage;
  final String doctorSlug;

  RecentConsultation({
    required this.id,
    required this.type,
    required this.status,
    required this.scheduledAt,
    required this.doctorName,
    this.doctorImage,
    required this.doctorSlug,
  });

  factory RecentConsultation.fromJson(Map<String, dynamic> json) {
    return RecentConsultation(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at'] as String? ?? DateTime.now().toIso8601String()),
      doctorName: json['doctor_name'] as String? ?? '',
      doctorImage: json['doctor_image'] as String?,
      doctorSlug: json['doctor_slug'] as String? ?? '',
    );
  }
}

class UpcomingAppointment {
  final int id;
  final String type;
  final String status;
  final DateTime scheduledAt;
  final String doctorName;
  final String? doctorImage;
  final String doctorSlug;
  final String patientName;
  final String patientType;
  final String? relationship;

  UpcomingAppointment({
    required this.id,
    required this.type,
    required this.status,
    required this.scheduledAt,
    required this.doctorName,
    this.doctorImage,
    required this.doctorSlug,
    required this.patientName,
    required this.patientType,
    this.relationship,
  });

  factory UpcomingAppointment.fromJson(Map<String, dynamic> json) {
    return UpcomingAppointment(
      id: json['id'] as int,
      type: json['type'] as String? ?? '',
      status: json['status'] as String? ?? '',
      scheduledAt: DateTime.parse(json['scheduled_at'] as String? ?? DateTime.now().toIso8601String()),
      doctorName: json['doctor_name'] as String? ?? '',
      doctorImage: json['doctor_image'] as String?,
      doctorSlug: json['doctor_slug'] as String? ?? '',
      patientName: json['patient_name'] as String? ?? '',
      patientType: json['patient_type'] as String? ?? 'self',
      relationship: json['relationship'] as String?,
    );
  }
}

class FollowUpChatSummary {
  final int id;
  final int appointmentId;
  final String doctorName;
  final String? doctorImage;
  final String latestMessage;
  final int unreadCount;
  final DateTime latestMessageAt;

  FollowUpChatSummary({
    required this.id,
    required this.appointmentId,
    required this.doctorName,
    this.doctorImage,
    required this.latestMessage,
    required this.unreadCount,
    required this.latestMessageAt,
  });

  factory FollowUpChatSummary.fromJson(Map<String, dynamic> json) {
    return FollowUpChatSummary(
      id: json['id'] as int,
      appointmentId: json['appointment_id'] as int,
      doctorName: json['doctor_name'] as String? ?? '',
      doctorImage: json['doctor_image'] as String?,
      latestMessage: json['latest_message'] as String? ?? '',
      unreadCount: json['unread_count'] as int? ?? 0,
      latestMessageAt: DateTime.parse(json['latest_message_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }
}

