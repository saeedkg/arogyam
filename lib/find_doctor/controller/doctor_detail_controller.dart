import 'package:arogyam/_shared/utils/date_time_formatter.dart';
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
  final Rxn<TimeSlot> selectedSlot = Rxn<TimeSlot>();
  final RxList<TimeSlot> availableSlots = <TimeSlot>[].obs;

  Future<void> load(String id) async {
    isLoading.value = true;
    try {
      final d = await service.fetchDoctorDetail(id);
      detail.value = d;
      selectedDateIndex.value = 0;
      selectedTime.value = '';
      selectedSlot.value = null;
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
    final convertedSlots = availableSlots.map((slot) =>DateTimeFormatter.toLocal (slot.datetime)).toList();

    return convertedSlots.map((dt) {
      final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
      final amPm = dt.hour >= 12 ? 'PM' : 'AM';
      final minute = dt.minute.toString().padLeft(2, '0');
      return '${hour.toString().padLeft(2, '0')}:$minute $amPm';
    }).toList();
  }
}

