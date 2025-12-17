import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../_shared/constants/network_config.dart';
import '../entities/dashboard_data.dart';

class DashboardService {
  final NetworkAdapter _networkAdapter;

  DashboardService({NetworkAdapter? networkAdapter}) 
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<DashboardData> fetchDashboardData() async {
    final url = '${NetworkConfig.baseUrl}/patient/dashboard';
    final apiRequest = APIRequest(url);
    
    try {
      final res = await _networkAdapter.get(apiRequest);
      if (res.data is Map<String, dynamic>) {
        return DashboardData.fromJson(res.data as Map<String, dynamic>);
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
        throw ServerSentException('Failed to fetch dashboard data', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}