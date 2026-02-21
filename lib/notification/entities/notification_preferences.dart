class NotificationPreferences {
  final GlobalPreferences global;
  final QuietHours? quietHours;
  final List<NotificationTypePreference> notificationTypes;

  NotificationPreferences({
    required this.global,
    this.quietHours,
    required this.notificationTypes,
  });

  factory NotificationPreferences.fromJson(Map<String, dynamic> json) {
    return NotificationPreferences(
      global: GlobalPreferences.fromJson(json['global'] as Map<String, dynamic>),
      quietHours: json['quiet_hours'] != null
          ? QuietHours.fromJson(json['quiet_hours'] as Map<String, dynamic>)
          : null,
      notificationTypes: (json['notification_types'] as List)
          .map((e) => NotificationTypePreference.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'global': global.toJson(),
      'quiet_hours': quietHours?.toJson(),
      'notification_types': notificationTypes.map((e) => e.toJson()).toList(),
    };
  }
}

class GlobalPreferences {
  final bool notificationsEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  GlobalPreferences({
    required this.notificationsEnabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory GlobalPreferences.fromJson(Map<String, dynamic> json) {
    return GlobalPreferences(
      notificationsEnabled: json['notifications_enabled'] as bool,
      soundEnabled: json['sound_enabled'] as bool,
      vibrationEnabled: json['vibration_enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notifications_enabled': notificationsEnabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
    };
  }
}

class QuietHours {
  final bool enabled;
  final String start;
  final String end;

  QuietHours({
    required this.enabled,
    required this.start,
    required this.end,
  });

  factory QuietHours.fromJson(Map<String, dynamic> json) {
    return QuietHours(
      enabled: json['enabled'] as bool,
      start: json['start'] as String,
      end: json['end'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'start': start,
      'end': end,
    };
  }
}

class NotificationTypePreference {
  final String type;
  final bool enabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  NotificationTypePreference({
    required this.type,
    required this.enabled,
    required this.soundEnabled,
    required this.vibrationEnabled,
  });

  factory NotificationTypePreference.fromJson(Map<String, dynamic> json) {
    return NotificationTypePreference(
      type: json['type'] as String,
      enabled: json['enabled'] as bool,
      soundEnabled: json['sound_enabled'] as bool,
      vibrationEnabled: json['vibration_enabled'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'enabled': enabled,
      'sound_enabled': soundEnabled,
      'vibration_enabled': vibrationEnabled,
    };
  }
}
