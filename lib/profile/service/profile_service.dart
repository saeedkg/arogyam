import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/profile_urls.dart';
import '../../auth/entities/user_profile.dart';

class ProfileService {
  final NetworkAdapter _networkAdapter;

  ProfileService.initWith(this._networkAdapter);

  ProfileService() : _networkAdapter = AROGYAMAPI();

  Future<UserProfile> getProfile() async {
    final url = ProfileUrls.getProfileUrl();
    final apiRequest = APIRequest(url);

    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data != null && apiResponse.data is Map<String, dynamic>) {
        final Map<String, dynamic> json = apiResponse.data as Map<String, dynamic>;
        final Map<String, dynamic>? data = json['data'] as Map<String, dynamic>?;
        if (data == null) {
          throw Exception('No data in response');
        }
        return UserProfile.fromJson(data);
      } else {
        throw Exception('No data in response');
      }
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
}


