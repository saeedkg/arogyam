import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../_shared/constants/network_config.dart';
import '../entities/hospital_detail.dart';

class HospitalService {
  final NetworkAdapter _networkAdapter;

  HospitalService({NetworkAdapter? networkAdapter}) 
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Fetch hospital details by ID
  Future<HospitalDetail> fetchHospitalDetail(String hospitalId) async {
    final url = '${NetworkConfig.baseUrl}/patient/hospitals/$hospitalId';
    final apiRequest = APIRequest(url);
    
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      
      if (apiResponse.data is Map<String, dynamic>) {
        final data = apiResponse.data as Map<String, dynamic>;
        if (data['success'] == true && data['data'] != null) {
          return HospitalDetail.fromJson(data['data']);
        } else {
          throw Exception(data['message'] ?? 'Failed to fetch hospital details');
        }
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
        throw ServerSentException('Failed to fetch hospital details', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}