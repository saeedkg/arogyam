import 'package:get/get.dart';
import '../../common_services/entities/specialization.dart';
import '../../common_services/services/specialization_service.dart';
import '../entities/popular_specialty.dart';
import '../entities/common_symptom.dart';
import '../entities/health_concern.dart';
import '../service/care_discovery_data_service.dart';

class CareDiscoveryController extends GetxController {
  final SpecializationService specializationService;
  final CareDiscoveryDataService dataService;
  
  CareDiscoveryController({
    SpecializationService? specializationService,
    CareDiscoveryDataService? dataService,
  }) : specializationService = specializationService ?? SpecializationService(),
       dataService = dataService ?? CareDiscoveryDataService();

  // Existing properties
  final RxBool isLoading = false.obs;
  final RxList<Specialization> specializations = <Specialization>[].obs;
  
  // New properties for redesigned sections
  final RxList<PopularSpecialty> popularSpecialties = <PopularSpecialty>[].obs;
  final RxList<CommonSymptom> commonSymptoms = <CommonSymptom>[].obs;
  final RxList<HealthConcern> healthConcerns = <HealthConcern>[].obs;
  
  // Loading states for individual sections
  final RxBool isLoadingPopularSpecialties = false.obs;
  final RxBool isLoadingCommonSymptoms = false.obs;
  final RxBool isLoadingHealthConcerns = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadAllData();
  }

  /// Load all data concurrently
  Future<void> loadAllData() async {
    await Future.wait([
      loadSpecializations(),
      loadPopularSpecialties(),
      loadCommonSymptoms(),
      loadHealthConcerns(),
    ]);
  }

  /// Load specializations from API (existing method)
  Future<void> loadSpecializations() async {
    isLoading.value = true;
    try {
      final items = await specializationService.fetchSpecializations();
      specializations.assignAll(items);
    } catch (e) {
      // Handle error silently or show error message
      print('Error loading specializations: $e');
    } finally {
      isLoading.value = false;
    }
  }

  /// Load popular specialties (hardcoded data)
  Future<void> loadPopularSpecialties() async {
    isLoadingPopularSpecialties.value = true;
    try {
      final items = await dataService.fetchPopularSpecialties();
      popularSpecialties.assignAll(items);
    } catch (e) {
      print('Error loading popular specialties: $e');
    } finally {
      isLoadingPopularSpecialties.value = false;
    }
  }

  /// Load common symptoms (hardcoded data)
  Future<void> loadCommonSymptoms() async {
    isLoadingCommonSymptoms.value = true;
    try {
      final items = await dataService.fetchCommonSymptoms();
      commonSymptoms.assignAll(items);
    } catch (e) {
      print('Error loading common symptoms: $e');
    } finally {
      isLoadingCommonSymptoms.value = false;
    }
  }

  /// Load health concerns (hardcoded data)
  Future<void> loadHealthConcerns() async {
    isLoadingHealthConcerns.value = true;
    try {
      final items = await dataService.fetchHealthConcerns();
      healthConcerns.assignAll(items);
    } catch (e) {
      print('Error loading health concerns: $e');
    } finally {
      isLoadingHealthConcerns.value = false;
    }
  }

  /// Retry loading specializations on error
  Future<void> retryLoadSpecializations() async {
    await loadSpecializations();
  }
}
