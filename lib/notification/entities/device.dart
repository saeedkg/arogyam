class Device {
  final int id;
  final String deviceId;
  final String deviceName;
  final String deviceType;
  final String? deviceModel;
  final String? deviceOsVersion;
  final String? appVersion;
  final bool isActive;
  final bool isPrimary;
  final bool notificationsEnabled;
  final DateTime? lastUsedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  Device({
    required this.id,
    required this.deviceId,
    required this.deviceName,
    required this.deviceType,
    this.deviceModel,
    this.deviceOsVersion,
    this.appVersion,
    required this.isActive,
    required this.isPrimary,
    required this.notificationsEnabled,
    this.lastUsedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as int,
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
      deviceModel: json['device_model'] as String?,
      deviceOsVersion: json['device_os_version'] as String?,
      appVersion: json['app_version'] as String?,
      isActive: json['is_active'] as bool,
      isPrimary: json['is_primary'] as bool,
      notificationsEnabled: json['notifications_enabled'] as bool,
      lastUsedAt: json['last_used_at'] != null
          ? DateTime.parse(json['last_used_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
      'device_model': deviceModel,
      'device_os_version': deviceOsVersion,
      'app_version': appVersion,
      'is_active': isActive,
      'is_primary': isPrimary,
      'notifications_enabled': notificationsEnabled,
      'last_used_at': lastUsedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
