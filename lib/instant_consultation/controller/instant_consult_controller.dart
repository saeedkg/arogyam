import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import '../entities/instant_doctor.dart';
import '../entities/pricing.dart';
import '../entities/payment_order.dart';
import '../entities/complete_payment_response.dart';
import '../service/instant_consult_service.dart';
import '../../_shared/patient/current_patient_controller.dart';

class InstantConsultController extends GetxController {
  final InstantConsultService api;
  late Razorpay _razorpay;

  InstantConsultController({InstantConsultService? api})
      : api = api ?? InstantConsultService();

  final RxBool isLoading = false.obs;
  final RxList<InstantDoctor> availableDoctors = <InstantDoctor>[].obs;
  final RxBool isBooking = false.obs;
  final RxnString bookingError = RxnString();
  final RxnString appointmentId = RxnString();
  
  final RxBool isPricingLoading = false.obs;
  final Rxn<Pricing> pricing = Rxn<Pricing>();

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    loadAvailableDoctors();
    loadPricing();
  }

  @override
  void onClose() {
    _razorpay.clear();
    super.onClose();
  }

  Future<void> loadPricing() async {
    isPricingLoading.value = true;
    try {
      final pricingData = await api.fetchPricing();
      pricing.value = pricingData;
    } catch (e) {
      print('Error loading pricing: $e');
    } finally {
      isPricingLoading.value = false;
    }
  }

  Future<void> loadAvailableDoctors() async {
    isLoading.value = true;
    try {
      final doctors = await api.fetchInstantAvailableDoctors();
      availableDoctors.assignAll(doctors);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> initiatePayment() async {
    isBooking.value = true;
    bookingError.value = null;
    appointmentId.value = null;
    
    try {
      // Get the current patient controller to get selected family member
      final currentPatientController = Get.find<CurrentPatientController>();
      final selectedPatient = currentPatientController.current.value;
      final familyMemberId = selectedPatient?.id;
      
      // Step 1: Create payment order with family member ID
      final paymentOrder = await api.createPaymentOrder(familyMemberId: familyMemberId);
      
      // Step 2: Open Razorpay checkout
      var options = {
        'key': paymentOrder.razorpayKey,
        'amount': (paymentOrder.amount * 100).toInt(), // Amount in paise
        'currency': paymentOrder.currency,
        'name': 'Arogyam',
        'description': 'Instant Consultation',
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
      final result = await api.completePayment(
        razorpayPaymentId: response.paymentId ?? '',
        razorpayOrderId: response.orderId ?? '',
        razorpaySignature: response.signature ?? '',
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

