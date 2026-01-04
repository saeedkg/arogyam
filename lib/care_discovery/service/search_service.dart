import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../common_services/entities/specialization.dart';
import '../../common_services/constants/common_urls.dart';
import '../../find_doctor/entities/doctor_list_item.dart';
import '../../find_doctor/entities/doctor_filter.dart';
import '../../find_doctor/constants/doctor_urls.dart';

class SearchService {
  final NetworkAdapter _networkAdapter;

  SearchService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Fetch all specializations for local filtering
  Future<List<Specialization>> fetchSpecializations() async {
    final apiRequest = APIRequest(CommonUrls.getSpecializationsUrl());
    try {
      final res = await _networkAdapter.get(apiRequest);
      final data = res.data;

      if (data is Map<String, dynamic> &&
          data['data'] != null &&
          data['data']['specializations'] is List) {
        final List list = data['data']['specializations'];
        return list.map((e) => Specialization.fromJson(e)).toList();
      }

      throw Exception('Invalid specializations response format');
    } on APIException {
      rethrow;
    }
  }

  /// Search doctors using the API
  Future<List<DoctorListItem>> searchDoctors(DoctorFilter filter) async {
    final url = DoctorUrls.getDoctorsListUrl(
      page: 1,
      perPage: 20, // Get more results for search
      filter: filter,
    );
    
    final apiRequest = APIRequest(url);

    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      
      if (apiResponse.data is Map<String, dynamic>) {
        final map = apiResponse.data as Map<String, dynamic>;
        
        // Handle different response structures
        List<dynamic> list;
        if (map['data'] is List) {
          list = map['data'] as List<dynamic>;
        } else if (map['data'] != null && map['data']['doctors'] is List) {
          list = map['data']['doctors'] as List<dynamic>;
        } else if (map['doctors'] is List) {
          list = map['doctors'] as List<dynamic>;
        } else {
          list = [];
        }
        
        return list.map((e) => _mapToListItem(e as Map<String, dynamic>)).toList();
      }
      
      return [];
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        if (exception.responseData != null &&
            exception.responseData is Map<String, dynamic> &&
            (exception.responseData as Map<String, dynamic>)["message"] != null) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException('Failed to search doctors', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  /// Map API response to DoctorListItem
  DoctorListItem _mapToListItem(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final specs = (json['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specializationName = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final ratingStr = json['average_rating']?.toString();
    final rating = double.tryParse(ratingStr ?? '0') ?? 0.0;
    final reviews = (json['total_ratings'] is int) ? json['total_ratings'] as int : int.tryParse('${json['total_ratings'] ?? 0}') ?? 0;
    final fee = json["consultation_fee"] ?? "";
    final qualList = (json['qualifications'] as List<dynamic>? ?? []);
    final qualification = qualList.isNotEmpty
        ? qualList.map((e) => e.toString()).join(", ")
        : "Not available";

    // Map availability fields
    final availabilityStatus = json['availability_status'] as String?;
    final isOnline = availabilityStatus == 'online';
    final availableToday = json['available_today'] as bool? ?? false;

    // Map consultation types
    final consultationTypesRaw = json['consultation_types'] as List<dynamic>? ?? [];
    final consultationTypes = consultationTypesRaw.map((e) => e.toString()).toList();

    return DoctorListItem(
      id: '${json['id']}',
      name: (user != null ? (user['name'] as String?) : null) ?? 'Doctor',
      specialization: specializationName,
      hospital: 'Calicut',
      imageUrl: 'https://i.pravatar.cc/150?img=10',
      rating: rating,
      reviews: reviews,
      consultationFee: fee,
      favorite: false,
      education: qualification,
      isOnline: isOnline,
      availableToday: availableToday,
      consultationTypes: consultationTypes,
    );
  }
}