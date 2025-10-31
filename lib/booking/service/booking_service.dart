import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/booking_urls.dart';
import '../entities/appointment_booking_request.dart';
import '../entities/booking_response.dart';

class BookingService {
  final NetworkAdapter _networkAdapter;
  BookingService({NetworkAdapter? networkAdapter}) : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<BookingResponse> bookAppointment(AppointmentBookingRequest req) async {
    final apiRequest = APIRequest(BookingUrls.bookAppointmentUrl());
    apiRequest.addParameters(req.toJson());
    try {
      final res = await _networkAdapter.post(apiRequest);
      if (res.data is Map<String, dynamic>) {
        return BookingResponse.fromJson(res.data as Map<String, dynamic>);
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
        throw ServerSentException('Failed to book appointment', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}
