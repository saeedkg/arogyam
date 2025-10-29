
import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/auth_urls.dart';
import '../entities/verify_otp_response.dart';

class AuthService {
  final NetworkAdapter _networkAdapter;

  AuthService.initWith(
      this._networkAdapter,
      );

  AuthService()
     :
        _networkAdapter = AROGYAMAPI();

  Future<int> getOtp(String phoneNumber) async {

     var url = AuthUrls.getOtPUrl();
     var apiRequest = APIRequest(url);
     apiRequest.addParameters({
       'phone': phoneNumber,
     });

     try {
       var apiResponse = await _networkAdapter.post(apiRequest);
       
       // // Check if response indicates failure
       // if (apiResponse.data != null && apiResponse.data['success'] == false) {
       //   // Server sent a failure response with message, throw ServerSentException
       //   final message = apiResponse.data['message'] as String? ?? 'OTP request failed';
       //   final errorCode = apiResponse.data['errorCode'] ?? 0;
       //   throw ServerSentException(message, errorCode);
       // }
       
       // Extract expires_in from the response data

       if (apiResponse.data != null && apiResponse.data['expires_in'] != null) {
         final expiresInRaw = apiResponse.data['expires_in'];
         final expiresIn = int.tryParse(expiresInRaw.toString()) ?? 0;
         return expiresIn;
       } else {
         throw Exception('expires_in not found in response');
       }
     } on NetworkFailureException {
       throw NetworkFailureException(); // Re-throw with user-friendly message
     } on APIException catch (exception) {
       if (exception is HTTPException) {
         // Check if response data contains server message
         if (exception.responseData != null && 
             exception.responseData is Map<String, dynamic> &&
             exception.responseData["message"] != null) {
           final responseMap = exception.responseData as Map<String, dynamic>;
           final message = responseMap["message"] as String;
           final errorCode = responseMap["errorCode"] ?? exception.httpCode;
           throw ServerSentException(message, errorCode);
         }
         
         // Fallback to generic message
         throw ServerSentException('Invalid username or password', exception.httpCode);
       } else {
         rethrow;
       }
     }
  }

  Future<VerifyOtpResponse> verifyOtp({
    required String mobile,
    required String otp,
    String? name,
    String? email,
  }) async {
    var url = AuthUrls.getVerifyOtpUrl();
    var apiRequest = APIRequest(url);
    apiRequest.addParameters({
      'phone': mobile,
      'otp': otp,
      if (name != null) 'name': name,
      if (email != null) 'email': email,
    });

    try {
      var apiResponse = await _networkAdapter.post(apiRequest);
      
      // Check if response indicates failure
      // if (apiResponse.data != null && apiResponse.data['success'] == false) {
      //   // Server sent a failure response with message, throw ServerSentException
      //   final message = apiResponse.data['message'] as String? ?? 'Verification failed';
      //   final errorCode = apiResponse.data['errorCode'] ?? 0;
      //   throw ServerSentException(message, errorCode);
      // }
      
      if (apiResponse.data != null) {
        return VerifyOtpResponse.fromJson(apiResponse.data);
      } else {
        throw Exception('No data in response');
      }
    } on NetworkFailureException {
      throw NetworkFailureException(); // Re-throw with user-friendly message
          } on APIException catch (exception) {
        if (exception is HTTPException) {
          // Check if response data contains server message
          if (exception.responseData != null && 
              exception.responseData is Map<String, dynamic> &&
              exception.responseData["message"] != null) {
            final responseMap = exception.responseData as Map<String, dynamic>;
            final message = responseMap["message"] as String;
            final errorCode = responseMap["errorCode"] ?? exception.httpCode;
            throw ServerSentException(message, errorCode);
          }
          
          // Fallback to generic message
          throw ServerSentException('Invalid OTP', exception.httpCode);
        } else {
          rethrow;
        }
    }
  }

  /// Delete user account
  Future<bool> deleteAccount() async {
    var url = AuthUrls.deleteAccountUrl();
    var apiRequest = APIRequest(url);

    try {
      var apiResponse = await _networkAdapter.delete(apiRequest);
      // Check if the response indicates successful deletion
      if (apiResponse.data != null && apiResponse.data['success'] == true) {
        return true;
      } else {
        throw Exception('Failed to delete account');
      }
    } on NetworkFailureException {
      throw NetworkFailureException(); // Re-throw with user-friendly message
    } on APIException catch (exception) {
      rethrow;
    }
  }

  /// Logout user
  Future<bool> logout() async {
    var url = AuthUrls.logoutUrl();
    var apiRequest = APIRequest(url);

    try {
      var apiResponse = await _networkAdapter.post(apiRequest);
      // Check if the response indicates successful logout
      if (apiResponse.data != null && apiResponse.data['success'] == true) {
        return true;
      } else {
        throw Exception('Failed to logout');
      }
    } on NetworkFailureException {
      throw NetworkFailureException(); // Re-throw with user-friendly message
    } on APIException catch (exception) {
      rethrow;
    }
  }
}