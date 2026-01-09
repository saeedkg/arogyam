import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../entities/appointment_booking_request.dart';
import '../entities/booking_response.dart';
import '../entities/video_consultation_pricing.dart';
import '../entities/video_consultation_payment_order.dart';
import '../service/booking_service.dart';

class BookingController extends GetxController {
  final BookingService service;
  late Razorpay _razorpay;
  
  // Store payment context
  String? _currentDoctorId;
  String? _currentScheduledAt;
  String? _currentFamilyMemberId;
  String? _currentPatientNotes;

  BookingController({BookingService? service}) : service = service ?? BookingService();

  final RxBool isBooking = false.obs;
  final RxnString bookingError = RxnString();
  final Rxn<BookingResponse> bookingResult = Rxn<BookingResponse>();
  
  final RxBool isPricingLoading = false.obs;
  final Rxn<VideoConsultationPricing> pricing = Rxn<VideoConsultationPricing>();
  final RxnString appointmentId = RxnString();

  @override
  void onInit() {
    super.onInit();
    try {
      _razorpay = Razorpay();
      _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
      _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
      _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    } catch (e) {
      print('Error initializing Razorpay: $e');
    }
  }

  @override
  void onClose() {
    try {
      _razorpay.clear();
    } catch (e) {
      print('Error clearing Razorpay: $e');
    }
    super.onClose();
  }

  Future<void> loadPricing(String doctorId) async {
    isPricingLoading.value = true;
    try {
      final pricingData = await service.fetchVideoConsultationPricing(doctorId);
      pricing.value = pricingData;
    } catch (e) {
      print('Error loading pricing: $e');
    } finally {
      isPricingLoading.value = false;
    }
  }

  Future<void> book(AppointmentBookingRequest req) async {
    isBooking.value = true;
    bookingError.value = null;
    bookingResult.value = null;
    try {
      bookingResult.value = await service.bookAppointment(req);
    } catch (e) {
      bookingError.value = e.toString();
    } finally {
      isBooking.value = false;
    }
  }

  Future<void> initiatePayment({
    required String doctorId,
    required String scheduledAt,
    String? familyMemberId,
    String? patientNotes,
  }) async {
    isBooking.value = true;
    bookingError.value = null;
    appointmentId.value = null;
    
    // Store context for later use in payment completion
    _currentDoctorId = doctorId;
    _currentScheduledAt = scheduledAt;
    _currentFamilyMemberId = familyMemberId;
    _currentPatientNotes = patientNotes;
    
    try {
      // Validate required parameters
      if (doctorId.isEmpty || scheduledAt.isEmpty) {
        throw Exception('Invalid doctor ID or scheduled time');
      }
      
      // Step 1: Create payment order
      final paymentOrder = await service.createVideoConsultationOrder(
        doctorId: doctorId,
        scheduledAt: scheduledAt,
        familyMemberId: familyMemberId,
      );
      
      // Validate payment order response
      if (paymentOrder.orderId.isEmpty || paymentOrder.razorpayKey.isEmpty) {
        throw Exception('Invalid payment order received');
      }
      
      // Step 2: Open Razorpay checkout
      var options = {
        'key': paymentOrder.razorpayKey,
        'amount': paymentOrder.amountInPaise,
        'currency': paymentOrder.currency,
        'name': 'Arogyam',
        'description': 'Video Consultation',
        'order_id': paymentOrder.orderId,
        'prefill': {
          'contact': '',
          'email': ''
        },
        'theme': {
          'color': '#22C58B'
        }
      };
      
      // Ensure Razorpay is properly initialized before opening
      if (_razorpay == null) {
        throw Exception('Payment gateway not initialized');
      }
      
      _razorpay.open(options);
    } catch (e) {
      bookingError.value = 'Payment initialization failed: ${e.toString()}';
      isBooking.value = false;
      print('Error in initiatePayment: $e');
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Validate response data
      if (response.paymentId == null || response.paymentId!.isEmpty ||
          response.orderId == null || response.orderId!.isEmpty ||
          response.signature == null || response.signature!.isEmpty) {
        throw Exception('Invalid payment response data');
      }
      
      // Validate stored context
      if (_currentDoctorId == null || _currentScheduledAt == null) {
        throw Exception('Payment context lost');
      }
      
      // Step 3: Complete payment and create appointment
      final result = await service.completeVideoConsultationPayment(
        razorpayPaymentId: response.paymentId!,
        razorpayOrderId: response.orderId!,
        razorpaySignature: response.signature!,
        doctorId: _currentDoctorId!,
        scheduledAt: _currentScheduledAt!,
        familyMemberId: _currentFamilyMemberId,
        patientNotes: _currentPatientNotes,
      );
      
      // Validate appointment creation result
      if (result.appointmentId.isEmpty) {
        throw Exception('Failed to create appointment');
      }
      
      appointmentId.value = result.appointmentId;
    } catch (e) {
      bookingError.value = 'Payment completion failed: ${e.toString()}';
      print('Error in _handlePaymentSuccess: $e');
    } finally {
      isBooking.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    final errorMessage = response.message ?? 'Payment failed';
    bookingError.value = 'Payment failed: $errorMessage';
    isBooking.value = false;
    print('Payment error: ${response.code} - $errorMessage');
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    final walletName = response.walletName ?? 'Unknown wallet';
    bookingError.value = 'External wallet not supported: $walletName';
    isBooking.value = false;
    print('External wallet selected: $walletName');
  }
}
