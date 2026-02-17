class FollowUpEligibility {
  final bool isEligible;
  final String? reason;
  final DateTime expiresAt;
  final ExistingChat? existingChat;
  final int followUpDays;

  const FollowUpEligibility({
    required this.isEligible,
    this.reason,
    required this.expiresAt,
    this.existingChat,
    required this.followUpDays,
  });

  factory FollowUpEligibility.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    
    return FollowUpEligibility(
      isEligible: data['is_eligible'] as bool? ?? false,
      reason: data['reason'] as String?,
      expiresAt: DateTime.parse(data['expires_at'] as String? ?? DateTime.now().toIso8601String()),
      existingChat: data['existing_chat'] != null 
          ? ExistingChat.fromJson(data['existing_chat'] as Map<String, dynamic>)
          : null,
      followUpDays: data['follow_up_days'] as int? ?? 7,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
  bool get hasExistingChat => existingChat != null;
  bool get hasActiveChat => existingChat?.isActive == true;
  
  String get formattedExpiryTime {
    final now = DateTime.now();
    
    if (isExpired) {
      return 'Expired';
    }
    
    final difference = expiresAt.difference(now);
    if (difference.inDays > 0) {
      return '${difference.inDays} days left';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours left';
    } else {
      return '${difference.inMinutes} minutes left';
    }
  }
}

class ExistingChat {
  final int id;
  final bool isActive;
  final DateTime expiresAt;
  final DateTime createdAt;
  final int unreadCount;

  const ExistingChat({
    required this.id,
    required this.isActive,
    required this.expiresAt,
    required this.createdAt,
    this.unreadCount = 0,
  });

  factory ExistingChat.fromJson(Map<String, dynamic> json) {
    return ExistingChat(
      id: json['id'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? false,
      expiresAt: DateTime.parse(json['expires_at'] as String? ?? DateTime.now().toIso8601String()),
      createdAt: DateTime.parse(json['created_at'] as String? ?? DateTime.now().toIso8601String()),
      unreadCount: json['unread_count'] as int? ?? 0,
    );
  }

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}