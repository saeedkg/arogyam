import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../controller/enhanced_search_controller.dart';
import '../../find_doctor/ui/doctor_detail_info_screen.dart';
import 'consultation_type_selection_screen.dart';
import 'components/autocomplete_dropdown.dart';
import 'components/popular_searches_widget.dart';
import 'components/fuzzy_suggestions_widget.dart';
import 'components/search_result_card.dart';

class SearchScreen extends StatefulWidget {
  final String? initialQuery;
  final String? searchType;
  final AppointmentType? preSelectedAppointmentType;

  const SearchScreen({
    super.key,
    this.initialQuery,
    this.searchType,
    this.preSelectedAppointmentType,
  });

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final EnhancedSearchController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.put(EnhancedSearchController());

    // Set initial query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _controller.performSearch(widget.initialQuery!);
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded,
              size: 18,
              color: Colors.black87,
            ),
          ),
          onPressed: Get.back,
        ),
        title: const Text(
          'Search',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() => Column(
            children: [
              // Search Header
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                  child: TextField(
                    controller: _searchController,
                    autofocus: true,
                    onChanged: _controller.onSearchTextChanged,
                    decoration: InputDecoration(
                      hintText: 'Search doctors, symptoms or specialties',
                      hintStyle: TextStyle(
                        color: AppColors.grey500,
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: AppColors.grey600,
                        size: 22,
                      ),
                      suffixIcon: _controller.searchQuery.isNotEmpty
                          ? IconButton(
                              icon: Icon(
                                Icons.clear_rounded,
                                color: AppColors.grey600,
                                size: 20,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                _controller.clearSearch();
                              },
                            )
                          : null,
                      filled: true,
                      fillColor: AppColors.grey50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.grey200,
                          width: 1,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide(
                          color: AppColors.primaryGreen,
                          width: 2,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                    ),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    onSubmitted: (query) {
                      if (query.isNotEmpty) {
                        _controller.performSearch(query);
                      }
                    },
                  ),
                ),
              ),

              // Main Content with Autocomplete
              Expanded(
                child: Stack(
                  children: [
                    // Main Content
                    Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: _buildMainContent(),
                    ),

                    // Autocomplete Dropdown (Overlay)
                    if (_controller.showAutocomplete)
                      Positioned(
                        top: 16,
                        left: 0,
                        right: 0,
                        child: SingleChildScrollView(
                          child: AutocompleteDropdown(
                            suggestions: _controller.autocompleteSuggestions,
                            onSuggestionTapped: _handleSuggestionTap,
                            isLoading: _controller.isLoadingAutocomplete.value,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          )),
    );
  }

  Widget _buildMainContent() {
    // Loading state
    if (_controller.isSearching.value) {
      return _buildLoadingState();
    }

    // Error state
    if (_controller.showError) {
      return _buildErrorState();
    }

    // Popular searches (empty state)
    if (_controller.showPopularSearches) {
      return PopularSearchesWidget(
        popularSearches: _controller.popularSearches.value!,
        onPopularSearchTapped: (searchTerm) {
          _searchController.text = searchTerm;
          _controller.onPopularSearchTapped(searchTerm);
        },
        onTrendingSpecializationTapped: (spec) {
          _navigateToSpecialization(spec.name);
        },
      );
    }

    // Fuzzy suggestions (no results with suggestions)
    if (_controller.showFuzzySuggestions) {
      return FuzzySuggestionsWidget(
        suggestions: _controller.fuzzySuggestions.value!,
        onSuggestionTapped: (suggestion) {
          _searchController.text = suggestion.text;
          _controller.onDidYouMeanTapped(suggestion);
        },
      );
    }

    // No results (without suggestions)
    if (_controller.showNoResults) {
      return _buildNoResultsState();
    }

    // Search results
    if (_controller.showSearchResults) {
      return _buildSearchResults();
    }

    // Default empty state
    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              strokeWidth: 3,
            ),
            const SizedBox(height: 16),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: AppColors.errorRed,
            ),
            const SizedBox(height: 16),
            Text(
              'Oops!',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _controller.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _controller.retrySearch,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_rounded,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'Search for doctors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type symptoms, specialties, or doctor names',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 64,
              color: AppColors.grey400,
            ),
            const SizedBox(height: 16),
            Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try different keywords or browse all doctors',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Results header
          _buildResultsHeader(),
          const SizedBox(height: 16),

          // Search result cards
          ..._controller.searchResults.map((result) {
            return SearchResultCard(
              result: result,
              onTap: () => _handleResultTap(result),
            );
          }),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildResultsHeader() {
    final count = _controller.searchResults.length;
    return Row(
      children: [
        Container(
          width: 4,
          height: 24,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 12),
        const Text(
          'Results',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            '$count',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
        ),
      ],
    );
  }

  void _handleSuggestionTap(suggestion) {
    if (suggestion.type == 'doctor' && suggestion.slug != null) {
      // Navigate to doctor detail
      Get.to(() => DoctorDetailInfoScreen(doctorId: suggestion.id.toString()));
    } else if (suggestion.type == 'specialization') {
      // Navigate to specialization
      _navigateToSpecialization(suggestion.text);
    } else {
      // Perform search for symptom or other types
      _searchController.text = suggestion.text;
      _controller.onSuggestionTapped(suggestion);
    }
  }

  void _handleResultTap(result) {
    if (result.entityType == 'doctor') {
      Get.to(() => DoctorDetailInfoScreen(doctorId: result.id));
    }
  }

  void _navigateToSpecialization(String specializationName) {
    if (!mounted) return;

    if (widget.preSelectedAppointmentType != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpecialityDoctorsScreen(
            category: specializationName,
            appointmentType: widget.preSelectedAppointmentType,
          ),
        ),
      );
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultationTypeSelectionScreen(
            speciality: specializationName,
          ),
        ),
      ).then((result) {
        if (!mounted) return;
       // if (result != null && result.isSuccess && result.data != null) {
        if (result != null && result is AppointmentType) {

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialityDoctorsScreen(
                category: specializationName,
                appointmentType: result,
              ),
            ),
          );
        }
      });
    }
  }
}
