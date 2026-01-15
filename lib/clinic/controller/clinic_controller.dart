import 'package:get/get.dart';
import '../entities/clinic_detail.dart';
import '../service/clinic_service.dart';

class ClinicController extends GetxController {
  final ClinicService _clinicService;

  ClinicController({ClinicService? clinicService})
      : _clinicService = clinicService ?? ClinicService();

  final Rx<ClinicDetail?> clinicDetail = Rx<ClinicDetail?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;

  Future<void> loadClinicDetail(String clinicId) async {
    isLoading.value = true;
    errorMessage.value = '';
    clinicDetail.value = null;

    try {
      final detail = await _clinicService.getClinicDetail(clinicId);
      clinicDetail.value = detail;
    } catch (e) {
      errorMessage.value = e.toString();
      print('Error loading clinic detail: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void retry(String clinicId) {
    loadClinicDetail(clinicId);
  }
}
