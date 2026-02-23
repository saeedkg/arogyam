import '../../network/entities/api_request.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../_shared/constants/network_config.dart';
import '../entities/user_profile.dart';

class ProfileService {
  final NetworkAdapter _networkAdapter;

  ProfileService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<UserProfile> getProfile() async {
    final url = '${NetworkConfig.baseUrl}/patient/profile';
    final apiRequest = APIRequest(url);

    try {
      final response = await _networkAdapter.get(apiRequest);
      final map = response.data as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>;
      return UserProfile.fromJson(data);
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
        throw ServerSentException('Failed to fetch profile', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  Future<UserProfile> updateProfile({
    required String name,
    required String email,
    required String dateOfBirth,
    required String gender,
  }) async {
    final url = '${NetworkConfig.baseUrl}/patient/profile';
    final apiRequest = APIRequest(url);
    
    apiRequest.addParameters({
      'name': name,
      'email': email,
      'date_of_birth': dateOfBirth,
      'gender': gender,
    });

    try {
      final response = await _networkAdapter.put(apiRequest);
      final map = response.data as Map<String, dynamic>;
      final data = map['data'] as Map<String, dynamic>;
      return UserProfile.fromJson(data);
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
        throw ServerSentException('Failed to update profile', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}
