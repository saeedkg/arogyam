import 'package:get/get.dart';
import '../../common_services/entities/specialization.dart';
import '../../common_services/services/specialization_service.dart';

class CareDiscoveryController extends GetxController {
  final SpecializationService specializationService;
  
  CareDiscoveryController({
    SpecializationService? specializationService,
  }) : specializationService = specializationService ?? SpecializationService();

  final RxBool isLoading = false.obs;
  final RxList<Specialization> specializations = <Specialization>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadSpecializations();
  }

  Future<void> loadSpecializations() async {
    isLoading.value = true;
    try {
      final items = await specializationService.fetchSpecializations();
      specializations.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }
}
