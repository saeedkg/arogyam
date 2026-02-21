class DeviceSettingsRequest {
  final String? deviceName;
  final bool? notificationsEnabled;
  final bool? soundEnabled;
  final bool? vibrationEnabled;

  DeviceSettingsRequest({
    this.deviceName,
    this.notificationsEnabled,
    this.soundEnabled,
    this.vibrationEnabled,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    
    if (deviceName != null) data['device_name'] = deviceName;
    if (notificationsEnabled != null) data['notifications_enabled'] = notificationsEnabled;
    if (soundEnabled != null) data['sound_enabled'] = soundEnabled;
    if (vibrationEnabled != null) data['vibration_enabled'] = vibrationEnabled;
    
    return data;
  }
}
