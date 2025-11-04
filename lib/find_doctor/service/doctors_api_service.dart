import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../entities/doctor_list_item.dart';
import '../constants/doctor_urls.dart';
import '../../common_services/constants/common_urls.dart';

class DoctorsApiService {
  final NetworkAdapter _networkAdapter;

  DoctorsApiService.initWith(this._networkAdapter);

  DoctorsApiService() : _networkAdapter = AROGYAMAPI();

  Future<List<DoctorListItem>> fetchDoctorsList() async {
    final url = DoctorUrls.getDoctorsListUrl();
    final apiRequest = APIRequest(url);
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        final map = apiResponse.data as Map<String, dynamic>;
        final list = (map['data'] as List<dynamic>? ?? const []);
        return list.map((e) => _mapToListItem(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response');
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
        throw ServerSentException('Failed to load doctors', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  Future<List<DoctorListItem>> fetchDoctorsBySpecialization(String specialization) async {
    final url = CommonUrls.getDoctorsBySpecializationUrl(specialization);
    final apiRequest = APIRequest(url);
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        final map = apiResponse.data as Map<String, dynamic>;
        final list = (map['data'] as List<dynamic>? ?? const []);
        return list.map((e) => _mapToListItem(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response');
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
        throw ServerSentException('Failed to load doctors by specialization', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  DoctorListItem _mapToListItem(Map<String, dynamic> json) {
    // Minimal mapping for current UI needs
    final user = json['user'] as Map<String, dynamic>?;
    final specs = (json['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specializationName = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final ratingStr = json['average_rating']?.toString();
    final rating = double.tryParse(ratingStr ?? '0') ?? 0.0;
    final reviews = (json['total_ratings'] is int) ? json['total_ratings'] as int : int.tryParse('${json['total_ratings'] ?? 0}') ?? 0;

    return DoctorListItem(
      id: '${json['id']}',
      name: (user != null ? (user['name'] as String?) : null) ?? 'Doctor',
      specialization: specializationName,
      hospital: 'Calicut',
      imageUrl: 'https://i.pravatar.cc/150?img=10',
      rating: rating,
      reviews: reviews,
      favorite: false,
    );
  }
}


