import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/instant_consult_urls.dart';
import '../entities/instant_doctor.dart';

class InstantConsultService {
  final NetworkAdapter _networkAdapter;

  InstantConsultService.initWith(this._networkAdapter);

  InstantConsultService() : _networkAdapter = AROGYAMAPI();

  Future<List<InstantDoctor>> fetchInstantAvailableDoctors() async {
    final url = InstantConsultUrls.getInstantAvailableDoctorsUrl();
    final apiRequest = APIRequest(url);
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        final map = apiResponse.data as Map<String, dynamic>;
        final list = (map['data'] as List<dynamic>? ?? const []);
        return list.map((e) => _mapToInstantDoctor(e as Map<String, dynamic>)).toList();
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
        throw ServerSentException('Failed to load available doctors', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  InstantDoctor _mapToInstantDoctor(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final specs = (json['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specializationName = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final ratingStr = json['average_rating']?.toString();
    final rating = double.tryParse(ratingStr ?? '0') ?? 0.0;
    
    // Get profile image from user data
    final imageUrl = user?['profile_image'] as String? ?? 'https://i.pravatar.cc/150?img=10';

    return InstantDoctor(
      id: '${json['id']}',
      name: (user != null ? (user['name'] as String?) : null) ?? 'Doctor',
      specialization: specializationName,
      imageUrl: imageUrl,
      rating: rating,
    );
  }
}

