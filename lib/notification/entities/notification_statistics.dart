class NotificationStatistics {
  final OverallStats overall;
  final List<TypeStats> byType;
  final List<DeviceStats> byDevice;

  NotificationStatistics({
    required this.overall,
    required this.byType,
    required this.byDevice,
  });

  factory NotificationStatistics.fromJson(Map<String, dynamic> json) {
    return NotificationStatistics(
      overall: OverallStats.fromJson(json['overall'] as Map<String, dynamic>),
      byType: (json['by_type'] as List)
          .map((e) => TypeStats.fromJson(e as Map<String, dynamic>))
          .toList(),
      byDevice: (json['by_device'] as List)
          .map((e) => DeviceStats.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'overall': overall.toJson(),
      'by_type': byType.map((e) => e.toJson()).toList(),
      'by_device': byDevice.map((e) => e.toJson()).toList(),
    };
  }
}

class OverallStats {
  final int totalSent;
  final int totalDelivered;
  final int totalClicked;
  final int totalFailed;
  final double deliveryRate;
  final double clickRate;

  OverallStats({
    required this.totalSent,
    required this.totalDelivered,
    required this.totalClicked,
    required this.totalFailed,
    required this.deliveryRate,
    required this.clickRate,
  });

  factory OverallStats.fromJson(Map<String, dynamic> json) {
    return OverallStats(
      totalSent: json['total_sent'] as int,
      totalDelivered: json['total_delivered'] as int,
      totalClicked: json['total_clicked'] as int,
      totalFailed: json['total_failed'] as int,
      deliveryRate: (json['delivery_rate'] as num).toDouble(),
      clickRate: (json['click_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_sent': totalSent,
      'total_delivered': totalDelivered,
      'total_clicked': totalClicked,
      'total_failed': totalFailed,
      'delivery_rate': deliveryRate,
      'click_rate': clickRate,
    };
  }
}

class TypeStats {
  final String notificationType;
  final int totalSent;
  final int totalDelivered;
  final int totalClicked;
  final double deliveryRate;
  final double clickRate;

  TypeStats({
    required this.notificationType,
    required this.totalSent,
    required this.totalDelivered,
    required this.totalClicked,
    required this.deliveryRate,
    required this.clickRate,
  });

  factory TypeStats.fromJson(Map<String, dynamic> json) {
    return TypeStats(
      notificationType: json['notification_type'] as String,
      totalSent: json['total_sent'] as int,
      totalDelivered: json['total_delivered'] as int,
      totalClicked: json['total_clicked'] as int,
      deliveryRate: (json['delivery_rate'] as num).toDouble(),
      clickRate: (json['click_rate'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'notification_type': notificationType,
      'total_sent': totalSent,
      'total_delivered': totalDelivered,
      'total_clicked': totalClicked,
      'delivery_rate': deliveryRate,
      'click_rate': clickRate,
    };
  }
}

class DeviceStats {
  final String deviceId;
  final String deviceName;
  final int totalSent;
  final int totalDelivered;
  final int totalClicked;

  DeviceStats({
    required this.deviceId,
    required this.deviceName,
    required this.totalSent,
    required this.totalDelivered,
    required this.totalClicked,
  });

  factory DeviceStats.fromJson(Map<String, dynamic> json) {
    return DeviceStats(
      deviceId: json['device_id'] as String,
      deviceName: json['device_name'] as String,
      totalSent: json['total_sent'] as int,
      totalDelivered: json['total_delivered'] as int,
      totalClicked: json['total_clicked'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'total_sent': totalSent,
      'total_delivered': totalDelivered,
      'total_clicked': totalClicked,
    };
  }
}
