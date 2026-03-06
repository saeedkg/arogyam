import 'dart:async';
import 'package:get/get.dart';
import '../entities/search/search_suggestion.dart';
import '../entities/popular_searches.dart';
import '../service/enhanced_search_service.dart';

class EnhancedSearchController extends GetxController {
  final EnhancedSearchService _searchService;

  EnhancedSearchController({
    EnhancedSearchService? searchService,
  }) : _searchService = searchService ?? EnhancedSearchService();

  // Observable State
  final RxBool isLoading = false.obs;
  final RxBool isLoadingAutocomplete = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<SearchSuggestion> autocompleteSuggestions =
      <SearchSuggestion>[].obs;
  final Rx<PopularSearches?> popularSearches = Rx<PopularSearches?>(null);
  final RxBool hasSearched = false.obs;
  final RxString errorMessage = ''.obs;

  // Debouncing
  Timer? _debounceTimer;
  static const _debounceDuration = Duration(milliseconds: 300);

  @override
  void onInit() {
    super.onInit();
    loadPopularSearches();
  }

  @override
  void onClose() {
    _debounceTimer?.cancel();
    super.onClose();
  }

  /// Load popular searches on initialization
  Future<void> loadPopularSearches() async {
    isLoading.value = true;
    errorMessage.value = '';

    try {
      final result = await _searchService.getPopularSearches();
      popularSearches.value = result;
    } catch (e) {
      // Silently fail for popular searches - not critical
      errorMessage.value = '';
    } finally {
      isLoading.value = false;
    }
  }

  /// Handle search text changes with debouncing for autocomplete
  void onSearchTextChanged(String query) {
    searchQuery.value = query;

    // Cancel previous debounce timer
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      autocompleteSuggestions.clear();
      hasSearched.value = false;
      errorMessage.value = '';
      return;
    }

    if (query.trim().length < 2) {
      autocompleteSuggestions.clear();
      return;
    }

    // Debounce autocomplete
    _debounceTimer = Timer(_debounceDuration, () {
      _fetchAutocomplete(query);
    });
  }

  /// Fetch autocomplete suggestions
  Future<void> _fetchAutocomplete(String query) async {
    if (query.trim().length < 2) return;

    isLoadingAutocomplete.value = true;

    try {
      final suggestions = await _searchService.getAutocomplete(query);
      autocompleteSuggestions.assignAll(suggestions);
    } catch (e) {
      // Silently fail for autocomplete
      autocompleteSuggestions.clear();
    } finally {
      isLoadingAutocomplete.value = false;
    }
  }

  /// Handle suggestion tap
  void onSuggestionTapped(SearchSuggestion suggestion) {
    // Clear autocomplete
    autocompleteSuggestions.clear();

    // Update search query
    searchQuery.value = suggestion.text;

    // Navigation to doctor detail or specialization list - handled in UI
  }

  /// Handle popular search tap
  void onPopularSearchTapped(String searchTerm) {
    searchQuery.value = searchTerm;
    // Navigation handled in UI
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    autocompleteSuggestions.clear();
    hasSearched.value = false;
    errorMessage.value = '';
    _debounceTimer?.cancel();
  }

  // Getters for UI state

  bool get showPopularSearches =>
      searchQuery.isEmpty && !hasSearched.value && popularSearches.value != null;

  bool get showAutocomplete =>
      searchQuery.isNotEmpty &&
      searchQuery.value.length >= 2 &&
      autocompleteSuggestions.isNotEmpty &&
      !hasSearched.value;

  bool get showEmptyState =>
      searchQuery.isEmpty && !hasSearched.value && popularSearches.value == null;
}
