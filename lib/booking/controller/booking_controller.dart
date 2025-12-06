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
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void onClose() {
    _razorpay.clear();
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
      // Step 1: Create payment order
      final paymentOrder = await service.createVideoConsultationOrder(
        doctorId: doctorId,
        scheduledAt: scheduledAt,
        familyMemberId: familyMemberId,
      );
      
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
      
      _razorpay.open(options);
    } catch (e) {
      bookingError.value = e.toString();
      isBooking.value = false;
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    try {
      // Step 3: Complete payment and create appointment
      final result = await service.completeVideoConsultationPayment(
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
        doctorId: _currentDoctorId!,
        scheduledAt: _currentScheduledAt!,
        familyMemberId: _currentFamilyMemberId,
        patientNotes: _currentPatientNotes,
      );
      
      appointmentId.value = result.appointmentId;
    } catch (e) {
      bookingError.value = e.toString();
    } finally {
      isBooking.value = false;
    }
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    bookingError.value = 'Payment failed: ${response.message}';
    isBooking.value = false;
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    bookingError.value = 'External wallet selected: ${response.walletName}';
    isBooking.value = false;
  }
}
