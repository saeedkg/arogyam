import 'package:get/get.dart';
import '../entities/instant_doctor.dart';
import '../entities/pricing.dart';
import '../service/instant_consult_service.dart';
import '../../booking/entities/booking_response.dart';

class InstantConsultController extends GetxController {
  final InstantConsultService api;

  InstantConsultController({InstantConsultService? api})
      : api = api ?? InstantConsultService();

  final RxBool isLoading = false.obs;
  final RxList<InstantDoctor> availableDoctors = <InstantDoctor>[].obs;
  final RxBool isBooking = false.obs;
  final RxnString bookingError = RxnString();
  final Rxn<BookingResponse> bookingResult = Rxn<BookingResponse>();
  
  final RxBool isPricingLoading = false.obs;
  final Rxn<Pricing> pricing = Rxn<Pricing>();

  @override
  void onInit() {
    super.onInit();
    loadAvailableDoctors();
    loadPricing();
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

  Future<void> bookInstant({
    required String? patientId,
    required String symptoms,
    required String notes,
  }) async {
    isBooking.value = true;
    bookingError.value = null;
    bookingResult.value = null;
    try {
      final result = await api.bookInstantAppointment(
        patientId: patientId,
        symptoms: symptoms,
        notes: notes,
      );
      bookingResult.value = result;
    } catch (e) {
      bookingError.value = e.toString();
    } finally {
      isBooking.value = false;
    }
  }
}

