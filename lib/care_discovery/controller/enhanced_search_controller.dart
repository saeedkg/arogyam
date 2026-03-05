import 'dart:async';
import 'package:get/get.dart';
import '../entities/search_suggestion.dart';
import '../entities/popular_searches.dart';
import '../entities/search_result_item.dart';
import '../entities/fuzzy_suggestions.dart';
import '../service/enhanced_search_service.dart';

class EnhancedSearchController extends GetxController {
  final EnhancedSearchService _searchService;

  EnhancedSearchController({EnhancedSearchService? searchService})
      : _searchService = searchService ?? EnhancedSearchService();

  // Observable State
  final RxBool isLoading = false.obs;
  final RxBool isSearching = false.obs;
  final RxBool isLoadingAutocomplete = false.obs;
  final RxString searchQuery = ''.obs;
  final RxList<SearchSuggestion> autocompleteSuggestions =
      <SearchSuggestion>[].obs;
  final Rx<PopularSearches?> popularSearches = Rx<PopularSearches?>(null);
  final RxList<SearchResultItem> searchResults = <SearchResultItem>[].obs;
  final Rx<FuzzySuggestions?> fuzzySuggestions = Rx<FuzzySuggestions?>(null);
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
      searchResults.clear();
      fuzzySuggestions.value = null;
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

  /// Perform search with filters
  Future<void> performSearch(
    String query, {
    Map<String, dynamic>? filters,
  }) async {
    if (query.trim().isEmpty) return;

    searchQuery.value = query;
    hasSearched.value = true;
    isSearching.value = true;
    errorMessage.value = '';
    autocompleteSuggestions.clear();

    try {
      final result = await _searchService.universalSearch(
        query: query,
        entityType: filters?['entityType'] ?? 'doctor',
        specializationId: filters?['specializationId'],
        city: filters?['city'],
        state: filters?['state'],
        country: filters?['country'],
        latitude: filters?['latitude'],
        longitude: filters?['longitude'],
        consultationTypes: filters?['consultationTypes'],
        availableNow: filters?['availableNow'],
        minRating: filters?['minRating'],
        minFee: filters?['minFee'],
        maxFee: filters?['maxFee'],
        sortBy: filters?['sortBy'] ?? 'relevance',
        page: filters?['page'] ?? 1,
        perPage: filters?['perPage'] ?? 20,
      );

      searchResults.assignAll(result.results);
      fuzzySuggestions.value = result.suggestions;
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
      searchResults.clear();
      fuzzySuggestions.value = null;
    } finally {
      isSearching.value = false;
    }
  }

  /// Handle suggestion tap
  void onSuggestionTapped(SearchSuggestion suggestion) {
    // Clear autocomplete
    autocompleteSuggestions.clear();

    // Update search query
    searchQuery.value = suggestion.text;

    // Perform search based on suggestion type
    if (suggestion.type == 'symptom' || suggestion.type == 'specialization') {
      performSearch(suggestion.text);
    } else if (suggestion.type == 'doctor') {
      // Navigate to doctor detail - handled in UI
    }
  }

  /// Handle popular search tap
  void onPopularSearchTapped(String searchTerm) {
    searchQuery.value = searchTerm;
    performSearch(searchTerm);
  }

  /// Handle "Did you mean?" suggestion tap
  void onDidYouMeanTapped(SearchSuggestion suggestion) {
    searchQuery.value = suggestion.text;
    performSearch(suggestion.text);
  }

  /// Clear search
  void clearSearch() {
    searchQuery.value = '';
    searchResults.clear();
    autocompleteSuggestions.clear();
    fuzzySuggestions.value = null;
    hasSearched.value = false;
    errorMessage.value = '';
    _debounceTimer?.cancel();
  }

  /// Retry search after error
  Future<void> retrySearch() async {
    if (searchQuery.value.isNotEmpty) {
      await performSearch(searchQuery.value);
    }
  }

  // Getters for UI state

  bool get showPopularSearches =>
      searchQuery.isEmpty && !hasSearched.value && popularSearches.value != null;

  bool get showAutocomplete =>
      searchQuery.isNotEmpty &&
      searchQuery.value.length >= 2 &&
      autocompleteSuggestions.isNotEmpty &&
      !hasSearched.value;

  bool get showSearchResults =>
      hasSearched.value && searchResults.isNotEmpty && !isSearching.value;

  bool get showNoResults =>
      hasSearched.value &&
      searchResults.isEmpty &&
      !isSearching.value &&
      errorMessage.isEmpty;

  bool get showFuzzySuggestions =>
      showNoResults && (fuzzySuggestions.value?.hasSuggestions ?? false);

  bool get showError => errorMessage.isNotEmpty && !isSearching.value;

  bool get showEmptyState =>
      searchQuery.isEmpty && !hasSearched.value && popularSearches.value == null;

  // Helper Methods

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') || errorStr.contains('connection')) {
      return 'No internet connection. Please check your network.';
    } else if (errorStr.contains('503') ||
        errorStr.contains('service unavailable')) {
      return 'Search service is temporarily unavailable. Please try again.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else {
      return 'An error occurred. Please try again.';
    }
  }
}
