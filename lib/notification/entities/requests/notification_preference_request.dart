class NotificationPreferenceRequest {
  final String notificationType;
  final bool? enabled;
  final bool? soundEnabled;
  final bool? vibrationEnabled;

  NotificationPreferenceRequest({
    required this.notificationType,
    this.enabled,
    this.soundEnabled,
    this.vibrationEnabled,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'notification_type': notificationType,
    };
    
    if (enabled != null) data['enabled'] = enabled;
    if (soundEnabled != null) data['sound_enabled'] = soundEnabled;
    if (vibrationEnabled != null) data['vibration_enabled'] = vibrationEnabled;
    
    return data;
  }
}
