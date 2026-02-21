class DeviceRegistrationRequest {
  final String deviceId;
  final String? deviceName;
  final String deviceType;
  final String? deviceModel;
  final String? deviceOsVersion;
  final String? appVersion;
  final String fcmToken;

  DeviceRegistrationRequest({
    required this.deviceId,
    this.deviceName,
    required this.deviceType,
    this.deviceModel,
    this.deviceOsVersion,
    this.appVersion,
    required this.fcmToken,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'device_type': deviceType,
      'device_model': deviceModel,
      'device_os_version': deviceOsVersion,
      'app_version': appVersion,
      'fcm_token': fcmToken,
    };
  }
}
