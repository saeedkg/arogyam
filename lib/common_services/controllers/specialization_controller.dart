import 'package:get/get.dart';
import '../entities/specialization.dart';
import '../services/specialization_service.dart';

class SpecializationController extends GetxController {
  final SpecializationService service;
  
  SpecializationController({SpecializationService? service})
      : service = service ?? SpecializationService();

  final RxBool isLoading = false.obs;
  final RxList<Specialization> specializations = <Specialization>[].obs;
  final RxnString errorMessage = RxnString();

  @override
  void onInit() {
    super.onInit();
    fetchSpecializations();
  }

  Future<void> fetchSpecializations() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await service.fetchSpecializations();
      specializations.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}
