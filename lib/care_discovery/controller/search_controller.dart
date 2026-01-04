import 'package:get/get.dart';
import '../../common_services/entities/specialization.dart';
import '../../find_doctor/entities/doctor_list_item.dart';
import '../../find_doctor/entities/doctor_filter.dart';
import '../service/search_service.dart';

class CareSearchController extends GetxController {
  final SearchService _searchService;
  
  CareSearchController({SearchService? searchService})
      : _searchService = searchService ?? SearchService();

  // Observable states
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<Specialization> filteredSpecializations = <Specialization>[].obs;
  final RxList<DoctorListItem> filteredDoctors = <DoctorListItem>[].obs;
  final RxBool hasSearched = false.obs;

  // All data
  List<Specialization> _allSpecializations = [];
  
  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    isLoading.value = true;
    try {
      _allSpecializations = await _searchService.fetchSpecializations();
    } catch (e) {
      // Handle error silently for now
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> performSearch(String query) async {
    searchQuery.value = query;
    hasSearched.value = true;
    
    if (query.trim().isEmpty) {
      _clearResults();
      return;
    }

    isSearching.value = true;
    
    try {
      // Search specializations locally
      _filterSpecializations(query);
      
      // Search doctors via API
      await _searchDoctors(query);
    } catch (e) {
      // Handle error
      print('Search error: $e');
    } finally {
      isSearching.value = false;
    }
  }

  void _filterSpecializations(String query) {
    final filtered = _allSpecializations
        .where((spec) => spec.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    filteredSpecializations.assignAll(filtered);
  }

  Future<void> _searchDoctors(String query) async {
    try {
      final filter = DoctorFilter(searchQuery: query);
      final doctors = await _searchService.searchDoctors(filter);
      filteredDoctors.assignAll(doctors);
    } catch (e) {
      // Handle error
      filteredDoctors.clear();
    }
  }

  void _clearResults() {
    filteredSpecializations.clear();
    filteredDoctors.clear();
    hasSearched.value = false;
  }

  void clearSearch() {
    searchQuery.value = '';
    _clearResults();
  }

  // Getters for UI state
  bool get hasResults => filteredSpecializations.isNotEmpty || filteredDoctors.isNotEmpty;
  bool get showEmptyState => searchQuery.isEmpty && !hasSearched.value;
  bool get showNoResults => hasSearched.value && !hasResults && !isSearching.value;
  bool get showResults => hasSearched.value && hasResults;
}