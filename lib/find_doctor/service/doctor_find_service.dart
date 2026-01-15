import 'dart:math';
import '../entities/doctor_detail.dart';
import '../entities/time_slot.dart';
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

  Future<SlotsResponse> fetchDoctorSlots(String doctorId, String date) async {
    final url = DoctorUrls.getDoctorSlotsUrl(doctorId, date);
    final apiRequest = APIRequest(url);

    final apiResponse = await _networkAdapter.get(apiRequest);
    return SlotsResponse.fromJson(apiResponse.data as Map<String, dynamic>);
  }



  DoctorDetail _mapToDoctorDetail(Map<String, dynamic> json) {
    final id = '${json['id']}';
    final user = json['user'] as Map<String, dynamic>?;

    final name = user?['name'] as String? ?? 'Doctor';
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

    // Map new API fields
    final qualifications = (json['qualifications'] as List<dynamic>?)?.cast<String>();
    final languages = (json['languages'] as List<dynamic>?)?.cast<String>();
    final consultationTypes = (json['consultation_types'] as List<dynamic>?)?.cast<String>();
    final specializations = (json['specializations'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
    final clinics = (json['clinics'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
    final hospitals = (json['hospitals'] as List<dynamic>?)?.cast<Map<String, dynamic>>();
    final availabilityStatus = json['availability_status'] as String?;
    final availableToday = json['available_today'] as bool?;
    final todaySlotsCount = json['today_slots_count'] as int?;
    final totalConsultations = json['total_consultations'] as int?;
    final isVerified = json['is_verified'] as bool?;
    final consultationFee = json['consultation_fee']?.toString();
    
    // Get profile photo URL from API
    final profilePhotoUrl = json['profile_photo_url'] as String? ?? 'https://i.pravatar.cc/150?img=22';

    // Build availability for next 7 days
    final now = DateTime.now();
    final days = List<DateTime>.generate(7, (i) => DateTime(now.year, now.month, now.day + i));

    return DoctorDetail(
      id: id,
      name: name,
      specialization: specializationName,
      hospital: '',
      imageUrl: profilePhotoUrl,
      rating: rating,
      reviews: reviews,
      bio: bio,
      experienceYears: experienceYears,
      fee: fee,
      availableDates: days,
      qualifications: qualifications,
      languages: languages,
      consultationTypes: consultationTypes,
      specializations: specializations,
      clinics: clinics,
      hospitals: hospitals,
      availabilityStatus: availabilityStatus,
      availableToday: availableToday,
      todaySlotsCount: todaySlotsCount,
      totalConsultations: totalConsultations,
      isVerified: isVerified,
      consultationFee: consultationFee,
    );
  }
}

