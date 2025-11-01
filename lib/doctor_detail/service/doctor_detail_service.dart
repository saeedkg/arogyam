import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/doctor_detail_urls.dart';
import '../entities/doctor_detail_data.dart';

class DoctorDetailService {
  final NetworkAdapter _networkAdapter;
  DoctorDetailService({NetworkAdapter? networkAdapter}) : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<DoctorDetailData> getDoctorDetail(String doctorId) async {
    final url = DoctorDetailUrls.getDoctorDetailUrl(doctorId);
    final apiRequest = APIRequest(url);
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        return DoctorDetailData.fromJson(apiResponse.data as Map<String, dynamic>);
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
        throw ServerSentException('Failed to load doctor details', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}

