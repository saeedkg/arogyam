import '../../booking/constants/booking_urls.dart';
import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/appointment_urls.dart';
import '../entities/appointemet_detail.dart';
import '../entities/appointment.dart';

class AppointmentsService {
  final NetworkAdapter _networkAdapter;

  AppointmentsService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Fetch list of all appointments
  Future<List<Appointment>> fetchAppointments() async {
    final apiRequest = APIRequest(AppointmentsUrls.getAppointmentsUrl());
    try {
      final res = await _networkAdapter.get(apiRequest);
      final data = res.data;

      // Expected structure: { "data": { "data": [ ... ] } }
      if (data is Map<String, dynamic> &&
          data['data'] != null &&
          data['data']['data'] is List) {
        final List list = data['data']['data'];
        return list.map((e) => Appointment.fromJson(e)).toList();
      }

      throw Exception('Invalid appointments response format');
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        final responseMap = exception.responseData;
        if (responseMap != null &&
            responseMap is Map<String, dynamic> &&
            responseMap["message"] != null) {
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException(
            'Failed to load appointments', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  /// Fetch single appointment detail by ID
  Future<AppointmentDetail> fetchAppointmentDetail(int id) async {
    final apiRequest =
    APIRequest(AppointmentsUrls.getAppointmentDetailUrl(id));
    try {
      final res = await _networkAdapter.get(apiRequest);
      final data = res.data;

      // Expected structure: { "data": { ... } }
      if (data is Map<String, dynamic> && data['data'] != null) {
        return AppointmentDetail.fromJson(data['data']);
      }

      throw Exception('Invalid appointment detail response format');
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        final responseMap = exception.responseData;
        if (responseMap != null &&
            responseMap is Map<String, dynamic> &&
            responseMap["message"] != null) {
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException(
            'Failed to load appointment detail', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}
