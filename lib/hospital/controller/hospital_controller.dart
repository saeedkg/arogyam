import 'package:get/get.dart';
import '../entities/hospital_detail.dart';
import '../service/hospital_service.dart';

class HospitalController extends GetxController {
  final HospitalService _hospitalService;

  HospitalController({HospitalService? hospitalService})
      : _hospitalService = hospitalService ?? HospitalService();

  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final Rx<HospitalDetail?> hospitalDetail = Rx<HospitalDetail?>(null);

  /// Load hospital details
  Future<void> loadHospitalDetail(String hospitalId) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';
      hospitalDetail.value = null;

      final detail = await _hospitalService.fetchHospitalDetail(hospitalId);
      hospitalDetail.value = detail;
    } catch (e) {
      errorMessage.value = e.toString();
      hospitalDetail.value = null;
    } finally {
      isLoading.value = false;
    }
  }

  /// Retry loading hospital details
  Future<void> retry(String hospitalId) async {
    await loadHospitalDetail(hospitalId);
  }

  @override
  void onClose() {
    super.onClose();
  }
}
