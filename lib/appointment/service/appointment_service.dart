import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../entities/booking_detail.dart';
import '../../_shared/constants/network_config.dart';

class AppointmentService {
  final NetworkAdapter _networkAdapter;
  AppointmentService({NetworkAdapter? networkAdapter}) : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<BookingDetail> getAppointmentDetail(String appointmentId) async {
    final url = '${NetworkConfig.baseUrl}/patient/appointments/$appointmentId';
    final apiRequest = APIRequest(url);
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        return _mapToBookingDetail(apiResponse.data as Map<String, dynamic>);
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
        throw ServerSentException('Failed to load appointment details', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  BookingDetail _mapToBookingDetail(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final doctor = data['doctor'] as Map<String, dynamic>;
    final user = doctor['user'] as Map<String, dynamic>;
    final specs = (doctor['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specialization = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final scheduledAt = DateTime.parse(data['scheduled_at'] as String);
    final duration = doctor['consultation_duration'] as int? ?? 30;
    final endTime = scheduledAt.add(Duration(minutes: duration));

    return BookingDetail(
      id: '${data['id']}',
      doctorName: user['name'] as String? ?? 'Doctor',
      specialization: specialization,
      hospital: '',
      imageUrl: 'https://i.pravatar.cc/150?img=10',
      startTime: scheduledAt,
      endTime: endTime,
      status: data['status'] as String? ?? 'pending',
      prescriptionAvailable: data['prescription'] != null,
      prescriptionUrl: data['prescription']?['pdf_path'] as String?,
      amountPaid: double.tryParse(data['total_amount']?.toString() ?? '0') ?? 0.0,
      paymentStatus: data['payment_mode'] as String? ?? 'online',
      transactionId: data['payment']?['transaction_id'] as String? ?? '',
    );
  }
}

