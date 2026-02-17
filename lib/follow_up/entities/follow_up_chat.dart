class FollowUpChat {
  final int id;
  final int appointmentId;
  final String chatType;
  final bool isActive;
  final DateTime expiresAt;
  final DateTime createdAt;
  final FollowUpAppointment appointment;
  final ChatParticipant otherParticipant;
  final List<ChatMessage> messages;
  final int unreadCount;
  final ChatMessage? latestMessage;

  const FollowUpChat({
    required this.id,
    required this.appointmentId,
    required this.chatType,
    required this.isActive,
    required this.expiresAt,
    required this.createdAt,
    required this.appointment,
    required this.otherParticipant,
    required this.messages,
    required this.unreadCount,
    this.latestMessage,
  });

  factory FollowUpChat.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return FollowUpChat(
      id: data['id'] as int? ?? 0,
      appointmentId: data['appointment_id'] as int? ?? 0,
      chatType: data['chat_type'] as String? ?? 'follow_up',
      isActive: data['is_active'] as bool? ?? false,
      expiresAt: DateTime.parse(data['expires_at'] as String? ?? DateTime.now().add(const Duration(days: 7)).toIso8601String()),
      createdAt: DateTime.parse(data['created_at'] as String? ?? DateTime.now().toIso8601String()),
      appointment: FollowUpAppointment.fromJson(data['appointment'] as Map<String, dynamic>? ?? {}),
      otherParticipant: ChatParticipant.fromJson(data['other_participant'] as Map<String, dynamic>? ?? {}),
      messages: (data['messages'] as List<dynamic>? ?? [])
          .map((msg) => ChatMessage.fromJson(msg as Map<String, dynamic>))
          .toList(),
      unreadCount: data['unread_count'] as int? ?? 0,
      latestMessage: data['latest_message'] != null
          ? ChatMessage.fromJson(data['latest_message'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Create an empty chat for when no chat exists yet
  factory FollowUpChat.empty(int appointmentId) {
    return FollowUpChat(
      id: 0,
      appointmentId: appointmentId,
      chatType: 'follow_up',
      isActive: true,
      expiresAt: DateTime.now().add(const Duration(days: 7)),
      createdAt: DateTime.now(),
      appointment: FollowUpAppointment(
        id: appointmentId,
        scheduledAt: DateTime.now(),
        type: 'unknown',
        status: 'unknown',
      ),
      otherParticipant: const ChatParticipant(
        id: 0,
        name: 'Doctor',
        role: 'doctor',
      ),
      messages: [], // Empty array
      unreadCount: 0,
      latestMessage: null,
    );
  }
}

class FollowUpAppointment {
  final int id;
  final DateTime scheduledAt;
  final String type;
  final String status;

  const FollowUpAppointment({
    required this.id,
    required this.scheduledAt,
    required this.type,
    required this.status,
  });

  factory FollowUpAppointment.fromJson(Map<String, dynamic> json) {
    return FollowUpAppointment(
      id: json['id'] as int? ?? 0,
      scheduledAt: DateTime.parse(json['scheduled_at'] as String? ?? DateTime.now().toIso8601String()),
      type: json['type'] as String? ?? 'unknown',
      status: json['status'] as String? ?? 'unknown',
    );
  }
}

class ChatParticipant {
  final int id;
  final String name;
  final String role;

  const ChatParticipant({
    required this.id,
    required this.name,
    required this.role,
  });

  factory ChatParticipant.fromJson(Map<String, dynamic> json) {
    return ChatParticipant(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? 'Unknown',
      role: json['role'] as String? ?? 'unknown',
    );
  }
}

class ChatMessage {
  final int id;
  final int? senderId;
  final String senderType;
  final String senderName;
  final String message;
  final String messageType;
  final String? fileUrl;
  final String? fileName;
  final String? formattedFileSize;
  final bool isRead;
  final DateTime createdAt;

  const ChatMessage({
    required this.id,
    this.senderId,
    required this.senderType,
    required this.senderName,
    required this.message,
    required this.messageType,
    this.fileUrl,
    this.fileName,
    this.formattedFileSize,
    required this.isRead,
    required this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      id: json['id'] as int,
      senderId: json['sender_id'] as int?,
      senderType: json['sender_type'] as String? ?? 'unknown',
      senderName: json['sender_name'] as String? ?? 'Unknown',
      message: json['message'] as String? ?? '',
      messageType: json['message_type'] as String? ?? 'text',
      fileUrl: json['file_url'] as String?,
      fileName: json['file_name'] as String?,
      formattedFileSize: json['formatted_file_size'] as String?,
      isRead: json['is_read'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  bool get isFromPatient => senderType == 'patient';
  bool get isFromDoctor => senderType == 'doctor';
  bool get isSystemMessage => senderType == 'system';
  bool get isImageMessage => messageType == 'image';
  bool get isTextMessage => messageType == 'text';
  
  /// Check if message is from the current user (not from other participant)
  /// Messages from other participant should be on left, current user on right
  bool isFromCurrentUser(int otherParticipantId) {
    // System messages are neither
    if (isSystemMessage) return false;
    
    // If sender_id is null, treat as system message
    if (senderId == null) return false;
    
    // If sender_id matches other participant, it's from them (left side)
    // Otherwise it's from current user (right side)
    return senderId != otherParticipantId;
  }
}