import 'package:get/get.dart';
import '../../common_services/entities/specialization.dart';
import '../../common_services/services/specialization_service.dart';
import '../../landing/entities/doctor_list_item.dart';
import '../../landing/service/doctors_api_service.dart';

class DoctorsController extends GetxController {
  final DoctorsApiService api;
  final SpecializationService specializationService;

  DoctorsController({
    DoctorsApiService? api,
    SpecializationService? specializationService,
  }) : api = api ?? DoctorsApiService(),
        specializationService = specializationService ?? SpecializationService();

  final RxBool isLoading = false.obs;
  final RxBool isLoadingSpecializations = false.obs;
  final RxList<DoctorListItem> allDoctors = <DoctorListItem>[].obs;
  final RxList<DoctorListItem> filtered = <DoctorListItem>[].obs;
  final RxString query = ''.obs;
  final RxString activeFilter = 'All'.obs;
  final RxList<String> filters = <String>['All'].obs;
  String? _pendingFilter;

  @override
  void onInit() {
    super.onInit();
    load();
    loadSpecializations();
    ever(query, (_) => _apply());
    ever(activeFilter, (_) => loadDoctorsByFilter());
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final items = await api.fetchDoctorsList();
      allDoctors.assignAll(items);
      filtered.assignAll(items);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadDoctorsByFilter() async {
    isLoading.value = true;
    try {
      if (activeFilter.value == 'All') {
        final items = await api.fetchDoctorsList();
        allDoctors.assignAll(items);
        _apply();
      } else {
        final items = await api.fetchDoctorsBySpecialization(activeFilter.value);
        allDoctors.assignAll(items);
        _apply();
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadSpecializations() async {
    isLoadingSpecializations.value = true;
    try {
      final List<Specialization> specializations = await specializationService.fetchSpecializations();

      // Convert specializations to filter names
      final specializationNames = specializations.map((spec) => spec.name).toList();

      // Update filters with 'All' + specialization names
      filters.assignAll(['All', ...specializationNames]);
      
      // If there was a preselected category waiting, apply it now
      if (_pendingFilter != null && filters.contains(_pendingFilter)) {
        activeFilter.value = _pendingFilter!;
        _pendingFilter = null;
      }
    } catch (e) {
      // If API fails, fall back to default filters
      filters.assignAll(['All', 'General', 'Cardiologist', 'Dentist']);
    } finally {
      isLoadingSpecializations.value = false;
    }
  }

  void _apply() {
    final q = query.value.toLowerCase();
    filtered.assignAll(allDoctors.where((d) {
      final matchesQuery = q.isEmpty || d.name.toLowerCase().contains(q) || d.specialization.toLowerCase().contains(q);
      return matchesQuery;
    }));
  }

  // Method to set active filter from outside (for category navigation)
  void setActiveFilter(String filter) {
    if (isLoadingSpecializations.value || filters.length <= 1) {
      // Still loading or filters not loaded yet, store for later
      _pendingFilter = filter;
    } else if (filters.contains(filter)) {
      activeFilter.value = filter;
    }
  }
}