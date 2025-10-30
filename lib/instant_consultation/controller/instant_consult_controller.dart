import 'package:get/get.dart';
import '../entities/instant_doctor.dart';
import '../service/instant_consult_service.dart';

class InstantConsultController extends GetxController {
  final InstantConsultService api;

  InstantConsultController({InstantConsultService? api})
      : api = api ?? InstantConsultService();

  final RxBool isLoading = false.obs;
  final RxList<InstantDoctor> availableDoctors = <InstantDoctor>[].obs;

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
}

