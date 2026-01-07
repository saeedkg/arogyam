import 'dart:async';
import 'package:get/get.dart';
import '../../common_services/entities/specialization.dart';
import '../../common_services/services/specialization_service.dart';
import '../entities/doctor_list_item.dart';
import '../entities/doctor_filter.dart';
import '../service/doctors_get_detail_service.dart';
import '../../network/exceptions/network_failure_exception.dart';

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
  final RxList<DoctorListItem> doctors = <DoctorListItem>[].obs;
  final RxString query = ''.obs;
  final RxString activeFilter = 'All'.obs;
  final RxList<String> filters = <String>['All'].obs;
  final RxString errorMessage = ''.obs;
  final Rx<DoctorFilter> currentFilter = const DoctorFilter().obs;
  String? _pendingFilter;
  Timer? _searchDebounceTimer;

  @override
  void onInit() {
    super.onInit();
    loadSpecializations();
    // Note: Search debouncing is handled manually in the UI
    // to avoid conflicts with initialization
  }

  @override
  void onClose() {
    _searchDebounceTimer?.cancel();
    super.onClose();
  }

  Future<void> fetchInitialDoctors() async {
    _setLoading(true);
    _clearError();
    doctors.clear();
    try {
      // Build filter from current state
      _updateFilterFromState();
      
      // Pass filter to service
      final newDoctors = await api.fetchDoctorsList(
        reset: true,
        filter: currentFilter.value,
      );
      doctors.assignAll(newDoctors);
    } on NetworkFailureException {
      _setError('No internet connection. Please check your network and try again.');
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> fetchMoreDoctors() async {
    if (isLoading.value || api.didReachListEnd) return;
    _setLoading(true);
    _clearError();
    try {
      // Pass current filter to service
      final newDoctors = await api.fetchDoctorsList(
        filter: currentFilter.value,
      );
      doctors.addAll(newDoctors);
    } on NetworkFailureException {
      _setError('No internet connection. Please check your network and try again.');
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Update filter from current state (query, activeFilter)
  void _updateFilterFromState() {
    currentFilter.value = currentFilter.value.copyWith(
      searchQuery: query.value.isNotEmpty ? query.value : null,
      specialization: activeFilter.value != 'All' ? activeFilter.value : null,
    );
  }

  /// Set filter and fetch doctors
  void setFilter(DoctorFilter filter) {
    currentFilter.value = filter;
    fetchInitialDoctors();
  }

  /// Update sort and fetch
  void setSortBy(DoctorSortBy sortBy) {
    currentFilter.value = currentFilter.value.copyWith(sortBy: sortBy);
    fetchInitialDoctors();
  }

  /// Toggle quick filter and fetch
  void toggleQuickFilter(DoctorQuickFilter filter) {
    final newFilter = currentFilter.value.toggleQuickFilter(filter);
    // Only fetch if the filter actually changed
    if (newFilter != currentFilter.value) {
      currentFilter.value = newFilter;
      fetchInitialDoctors();
    }
  }

  /// Clear quick filters and fetch
  void clearQuickFilters() {
    final newFilter = currentFilter.value.clearQuickFilters();
    // Only fetch if there were actually filters to clear
    if (newFilter != currentFilter.value) {
      currentFilter.value = newFilter;
      fetchInitialDoctors();
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
      
      // If there was a preselected category waiting, apply it now but don't fetch
      if (_pendingFilter != null && filters.contains(_pendingFilter)) {
        activeFilter.value = _pendingFilter!;
        _pendingFilter = null;
        // Don't trigger fetch here - let the caller handle it
      }
    } catch (e) {
      // If API fails, fall back to default filters
      filters.assignAll(['All', 'General', 'Cardiologist', 'Dentist']);
      
      // Try to apply pending filter even with fallback filters
      if (_pendingFilter != null && filters.contains(_pendingFilter)) {
        activeFilter.value = _pendingFilter!;
        _pendingFilter = null;
        // Don't trigger fetch here - let the caller handle it
      }
    } finally {
      isLoadingSpecializations.value = false;
    }
  }

  void clearDoctors() {
    api.reset();
    doctors.clear();
    _clearError();
  }

  void _setLoading(bool loading) {
    isLoading.value = loading;
  }

  void _setError(String message) {
    errorMessage.value = message;
  }

  void _clearError() {
    errorMessage.value = '';
  }

  String _getErrorMessage(dynamic error) {
    if (error is NetworkFailureException) {
      return 'No internet connection. Please check your network and try again.';
    }
    return 'Something went wrong. Please try again.';
  }

  bool get hasDoctors => doctors.isNotEmpty;
  bool get didReachListEnd => api.didReachListEnd;

  // Method to set active filter from outside (for category navigation)
  void setActiveFilter(String filter) {
    // Just set the filter without triggering fetch - let the caller handle the fetch
    activeFilter.value = filter;
    
    if (filter == 'All') {
      return;
    }

    if (isLoadingSpecializations.value || filters.length <= 1) {
      // Still loading or filters not loaded yet, store for later
      _pendingFilter = filter;
    } else if (!filters.contains(filter)) {
      // Filter doesn't exist yet, store it for when specializations load
      _pendingFilter = filter;
    }
  }
}