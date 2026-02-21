class QuietHoursRequest {
  final bool enabled;
  final String? start;
  final String? end;

  QuietHoursRequest({
    required this.enabled,
    this.start,
    this.end,
  });

  Map<String, dynamic> toJson() {
    return {
      'enabled': enabled,
      'start': start,
      'end': end,
    };
  }
}
