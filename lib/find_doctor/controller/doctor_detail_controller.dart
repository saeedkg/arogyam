import 'package:get/get.dart';
import '../entities/doctor_detail.dart';
import '../service/doctor_booking_service.dart';

class DoctorDetailController extends GetxController {
  final DoctorBookingService service;
  DoctorDetailController({DoctorBookingService? service}) : service = service ?? DoctorBookingService();

  final RxBool isLoading = false.obs;
  final Rxn<DoctorDetail> detail = Rxn<DoctorDetail>();
  final RxInt selectedDateIndex = 0.obs;
  final RxString selectedTime = ''.obs;

  Future<void> load(String id) async {
    isLoading.value = true;
    try {
      final d = await service.fetchDoctorDetail(id);
      detail.value = d;
      selectedDateIndex.value = 0;
      selectedTime.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  List<String> get timesForSelectedDate {
    final d = detail.value;
    if (d == null) return [];
    final date = d.availableDates[selectedDateIndex.value];
    return d.timeSlots['${date.year}-${date.month}-${date.day}'] ?? [];
  }
}

