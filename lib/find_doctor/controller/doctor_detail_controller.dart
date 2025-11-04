import 'package:get/get.dart';
import '../entities/doctor_detail.dart';
import '../entities/time_slot.dart';
import '../service/doctor_find_service.dart';

class DoctorDetailController extends GetxController {
  final DoctorBookingService service;
  DoctorDetailController({DoctorBookingService? service}) : service = service ?? DoctorBookingService();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingSlots = false.obs;
  final Rxn<DoctorDetail> detail = Rxn<DoctorDetail>();
  final RxInt selectedDateIndex = 0.obs;
  final RxString selectedTime = ''.obs;
  final RxList<TimeSlot> availableSlots = <TimeSlot>[].obs;

  Future<void> load(String id) async {
    isLoading.value = true;
    try {
      final d = await service.fetchDoctorDetail(id);
      detail.value = d;
      selectedDateIndex.value = 0;
      selectedTime.value = '';
      // Load slots for the first date
      if (d.availableDates.isNotEmpty) {
        await loadSlotsForSelectedDate();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSlotsForSelectedDate() async {
    final d = detail.value;
    if (d == null) return;
    
    final date = d.availableDates[selectedDateIndex.value];
    final dateStr = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    
    isLoadingSlots.value = true;
    try {
      final response = await service.fetchDoctorSlots(d.id, dateStr);
      availableSlots.value = response.slots.where((slot) => slot.isAvailable).toList();
    } catch (e) {
      availableSlots.value = [];
    } finally {
      isLoadingSlots.value = false;
    }
  }

  List<String> get timesForSelectedDate {
    return availableSlots.map((slot) => slot.startTime).toList();
  }
}

