import 'package:get/get.dart';
import '../entities/doctor.dart';
import '../services/doctor_service.dart';

class DoctorController extends GetxController {
  final DoctorService service;
  
  DoctorController({DoctorService? service})
      : service = service ?? DoctorService();

  final RxBool isLoading = false.obs;
  final RxList<Doctor> doctors = <Doctor>[].obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchDoctors();
  }

  Future<void> fetchDoctors() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await service.fetchDoctors();
      doctors.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
