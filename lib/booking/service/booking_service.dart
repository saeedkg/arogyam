import '../../network/entities/api_request.dart';
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
    final res = await _networkAdapter.post(apiRequest);
    if (res.data is Map<String, dynamic>) {
      return BookingResponse.fromJson(res.data as Map<String, dynamic>);
    }
    throw Exception('Unexpected booking response');
  }
}
