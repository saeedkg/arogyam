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
import '../entities/video_consultation_pricing.dart';
import '../entities/video_consultation_payment_order.dart';
import '../entities/video_consultation_complete_payment_response.dart';

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

  Future<VideoConsultationPricing> fetchVideoConsultationPricing(String doctorId) async {
    final apiRequest = APIRequest(BookingUrls.videoConsultationPricingUrl());
    apiRequest.addParameter('doctor_id', doctorId);
    try {
      final res = await _networkAdapter.get(apiRequest);
      if (res.data is Map<String, dynamic>) {
        final data = (res.data as Map<String, dynamic>)['data'] as Map<String, dynamic>;
        return VideoConsultationPricing.fromJson(data);
      }
      throw Exception('Invalid response');
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        throw ServerSentException('Failed to fetch pricing', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  Future<VideoConsultationPaymentOrder> createVideoConsultationOrder({
    required String doctorId,
    required String scheduledAt,
    String? familyMemberId,
  }) async {
    final apiRequest = APIRequest(BookingUrls.videoConsultationCreateOrderUrl());
    apiRequest.addParameters({
      'doctor_id': doctorId,
      'scheduled_at': scheduledAt,
      if (familyMemberId != null && familyMemberId.toLowerCase() != 'self') 'family_member_id': familyMemberId,
    });
    try {
      final res = await _networkAdapter.post(apiRequest);
      if (res.data is Map<String, dynamic>) {
        return VideoConsultationPaymentOrder.fromJson(res.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response');
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        throw ServerSentException('Failed to create payment order', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  Future<VideoConsultationCompletePaymentResponse> completeVideoConsultationPayment({
    required String razorpayPaymentId,
    required String razorpayOrderId,
    required String razorpaySignature,
    required String doctorId,
    required String scheduledAt,
    String? familyMemberId,
    String? patientNotes,
  }) async {
    final apiRequest = APIRequest(BookingUrls.videoConsultationCompleteUrl());
    apiRequest.addParameters({
      'razorpay_payment_id': razorpayPaymentId,
      'razorpay_order_id': razorpayOrderId,
      'razorpay_signature': razorpaySignature,
      'doctor_id': doctorId,
      'scheduled_at': scheduledAt,
      if (familyMemberId != null && familyMemberId.toLowerCase() != 'self') 'family_member_id': familyMemberId,
      if (patientNotes != null) 'patient_notes': patientNotes,
    });
    try {
      final res = await _networkAdapter.post(apiRequest);
      if (res.data is Map<String, dynamic>) {
        return VideoConsultationCompletePaymentResponse.fromJson(res.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response');
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        throw ServerSentException('Failed to complete payment', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  Future<void> cancelPendingPayment(String appointmentId) async {
    final apiRequest = APIRequest(BookingUrls.cancelPendingPaymentUrl());
    apiRequest.addParameter('appointment_id', appointmentId);
    try {
      await _networkAdapter.post(apiRequest);
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
        throw ServerSentException('Failed to cancel pending payment', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}
