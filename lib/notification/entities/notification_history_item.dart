class NotificationHistoryItem {
  final int id;
  final String notificationType;
  final String title;
  final String body;
  final String status;
  final DateTime? sentAt;
  final DateTime? deliveredAt;
  final DateTime? clickedAt;
  final Map<String, dynamic>? data;
  final DeviceInfo? device;

  NotificationHistoryItem({
    required this.id,
    required this.notificationType,
    required this.title,
    required this.body,
    required this.status,
    this.sentAt,
    this.deliveredAt,
    this.clickedAt,
    this.data,
    this.device,
  });

  factory NotificationHistoryItem.fromJson(Map<String, dynamic> json) {
    return NotificationHistoryItem(
      id: json['id'] as int,
      notificationType: json['notification_type'] as String,
      title: json['title'] as String,
      body: json['body'] as String,
      status: json['status'] as String,
      sentAt: json['sent_at'] != null
          ? DateTime.parse(json['sent_at'] as String)
          : null,
      deliveredAt: json['delivered_at'] != null
          ? DateTime.parse(json['delivered_at'] as String)
          : null,
      clickedAt: json['clicked_at'] != null
          ? DateTime.parse(json['clicked_at'] as String)
          : null,
      data: json['data'] as Map<String, dynamic>?,
      device: json['device'] != null
          ? DeviceInfo.fromJson(json['device'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'notification_type': notificationType,
      'title': title,
      'body': body,
      'status': status,
      'sent_at': sentAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
      'clicked_at': clickedAt?.toIso8601String(),
      'data': data,
      'device': device?.toJson(),
    };
  }
}

class DeviceInfo {
  final int id;
  final String deviceName;
  final String deviceType;

  DeviceInfo({
    required this.id,
    required this.deviceName,
    required this.deviceType,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      id: json['id'] as int,
      deviceName: json['device_name'] as String,
      deviceType: json['device_type'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'device_name': deviceName,
      'device_type': deviceType,
    };
  }
}
