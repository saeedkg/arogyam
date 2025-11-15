import 'package:get/get.dart';
import '../entities/instant_doctor.dart';
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

  @override
  void onInit() {
    super.onInit();
    loadAvailableDoctors();
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

