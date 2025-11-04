class TimeSlot {
  final String startTime;
  final String endTime;
  final String datetime;
  final String consultationType;
  final String? clinicId;
  final bool isAvailable;

  const TimeSlot({
    required this.startTime,
    required this.endTime,
    required this.datetime,
    required this.consultationType,
    this.clinicId,
    required this.isAvailable,
  });

  factory TimeSlot.fromJson(Map<String, dynamic> json) {
    return TimeSlot(
      startTime: json['start_time'] as String,
      endTime: json['end_time'] as String,
      datetime: json['datetime'] as String,
      consultationType: json['consultation_type'] as String,
      clinicId: json['clinic_id'] as String?,
      isAvailable: json['is_available'] as bool? ?? true,
    );
  }
}

class SlotsResponse {
  final String date;
  final List<TimeSlot> slots;
  final int totalSlots;

  const SlotsResponse({
    required this.date,
    required this.slots,
    required this.totalSlots,
  });

  factory SlotsResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return SlotsResponse(
      date: data['date'] as String,
      slots: (data['slots'] as List<dynamic>)
          .map((e) => TimeSlot.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalSlots: data['total_slots'] as int,
    );
  }
}
