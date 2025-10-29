import 'dart:math';
import '../entities/doctor_detail.dart';
import '../../network/entities/api_request.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/doctor_urls.dart';

class DoctorBookingService {
  final NetworkAdapter _networkAdapter;

  DoctorBookingService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<DoctorDetail> fetchDoctorDetail(String id) async {
    final url = DoctorUrls.getDoctorDetailUrl(id);
    final apiRequest = APIRequest(url);

    final apiResponse = await _networkAdapter.get(apiRequest);
    final map = apiResponse.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>;

    return _mapToDoctorDetail(data);
  }

  Future<bool> confirmBooking({required String doctorId, required DateTime date, required String timeSlot}) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    return true;
  }

  String _key(DateTime d) => '${d.year}-${d.month}-${d.day}';

  DoctorDetail _mapToDoctorDetail(Map<String, dynamic> json) {
    final id = '${json['id']}';
    final name = json['name'] as String? ?? 'Doctor';
    final bio = json['bio'] as String? ?? '';
    final specializationName = ((json['specializations'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .where((e) => e['name'] != null)
            .map((e) => e['name'] as String)
            .toList()
            .cast<String>())
        .firstOrNull ??
        'General';
    final experienceYears = ((json['specializations'] as List<dynamic>? ?? const [])
            .cast<Map<String, dynamic>>()
            .map((e) => e['years_of_experience'])
            .where((e) => e != null)
            .map((e) => e is int ? e : int.tryParse('$e') ?? 0)
            .toList())
        .fold<int>(0, (prev, el) => max(prev, el));
    final rating = double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0;
    final reviews = json['total_ratings'] is int ? json['total_ratings'] as int : int.tryParse('${json['total_ratings'] ?? 0}') ?? 0;
    final fee = ((json['consultation_fee'] != null)
            ? double.tryParse(json['consultation_fee'].toString())
            : null)
            ?.round() ?? 0;

    // Build availability for next 4 days from weekly_availability
    final now = DateTime.now();
    final days = List<DateTime>.generate(4, (i) => DateTime(now.year, now.month, now.day + i));
    final Map<String, List<String>> timeSlots = {};
    final weekly = json['weekly_availability'] as Map<String, dynamic>? ?? {};
    for (final d in days) {
      final weekdayKey = _weekdayKey(d.weekday);
      final dayInfo = weekly[weekdayKey] as Map<String, dynamic>?;
      final slots = <String>[];
      if (dayInfo != null && dayInfo['is_available'] == true) {
        final ranges = (dayInfo['slots'] as List<dynamic>? ?? const []);
        for (final r in ranges) {
          final rm = r as Map<String, dynamic>;
          final start = DateTime.tryParse(rm['start_time'] as String? ?? '');
          final end = DateTime.tryParse(rm['end_time'] as String? ?? '');
          if (start != null && end != null) {
            slots.addAll(_generateSlots(start, end, 15));
          }
        }
      }
      timeSlots[_key(d)] = slots;
    }

    return DoctorDetail(
      id: id,
      name: name,
      specialization: specializationName,
      hospital: '',
      imageUrl: 'https://i.pravatar.cc/150?img=22',
      rating: rating,
      reviews: reviews,
      bio: bio,
      experienceYears: experienceYears,
      fee: fee,
      availableDates: days,
      timeSlots: timeSlots,
    );
  }

  List<String> _generateSlots(DateTime start, DateTime end, int intervalMinutes) {
    final list = <String>[];
    var t = start;
    while (!t.isAfter(end)) {
      list.add(_formatTime(t));
      t = t.add(Duration(minutes: intervalMinutes));
    }
    return list;
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour % 12 == 0 ? 12 : dt.hour % 12;
    final minute = dt.minute.toString().padLeft(2, '0');
    final ampm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${hour.toString().padLeft(2, '0')}:$minute $ampm';
  }

  String _weekdayKey(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'monday';
      case DateTime.tuesday:
        return 'tuesday';
      case DateTime.wednesday:
        return 'wednesday';
      case DateTime.thursday:
        return 'thursday';
      case DateTime.friday:
        return 'friday';
      case DateTime.saturday:
        return 'saturday';
      case DateTime.sunday:
        return 'sunday';
      default:
        return 'monday';
    }
  }
}

