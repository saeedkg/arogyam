import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../controller/enhanced_search_controller.dart';
import '../../find_doctor/ui/doctor_detail_info_screen.dart';
import 'consultation_type_selection_screen.dart';
import 'components/popular_searches_widget.dart';
import 'components/fuzzy_suggestions_widget.dart';
import 'components/search_result_card.dart';
import 'components/no_results_widget.dart';

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
      body: SafeArea(
        child: Obx(() => Column(
              children: [
                // Professional Search Header
                _buildSearchHeader(),

                // Main Content with Autocomplete
                Expanded(
                  child: _controller.showAutocomplete
                      ? _buildAutocompleteView()
                      : _buildMainContent(),
                ),
              ],
            )),
      ),
    );
  }

  Widget _buildSearchHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Top Bar with Back Button and Title
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Row(
              children: [
                // Back Button
                Material(
                  color: AppColors.grey100,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    onTap: Get.back,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      child: Icon(
                        Icons.arrow_back_ios_rounded,
                        size: 20,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Title
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Find Your Doctor',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Search by symptoms, specialties or names',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: AppColors.grey600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Search Field
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.grey50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.grey200,
                  width: 1,
                ),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: _controller.onSearchTextChanged,
                decoration: InputDecoration(
                  hintText: 'Search doctors, symptoms...',
                  hintStyle: TextStyle(
                    color: AppColors.grey400,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                  ),
                  prefixIcon: Container(
                    padding: const EdgeInsets.all(12),
                    child: Icon(
                      Icons.search_rounded,
                      color: AppColors.primaryGreen,
                      size: 24,
                    ),
                  ),
                  suffixIcon: _controller.searchQuery.isNotEmpty
                      ? IconButton(
                          icon: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: AppColors.grey200,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close_rounded,
                              color: AppColors.grey600,
                              size: 16,
                            ),
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
                    borderSide: BorderSide.none,
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
                    vertical: 16,
                  ),
                ),
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
                onSubmitted: (query) {
                  if (query.isNotEmpty) {
                    _controller.performSearch(query);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    // Loading state (initial load)
    if (_controller.isLoading.value && !_controller.hasSearched.value) {
      return _buildInitialLoadingState();
    }

    // Searching state
    if (_controller.isSearching.value) {
      return _buildLoadingState();
    }

    // Error state
    if (_controller.showError) {
      return _buildErrorState();
    }

    // Popular searches (empty state with data)
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
      return NoResultsWidget(
        searchQuery: _controller.searchQuery.value,
      );
    }

    // Search results
    if (_controller.showSearchResults) {
      return _buildSearchResults();
    }

    // Default empty state (only when no popular searches loaded)
    if (_controller.showEmptyState) {
      return _buildEmptyState();
    }

    // Fallback
    return _buildEmptyState();
  }

  Widget _buildAutocompleteView() {
    if (_controller.isLoadingAutocomplete.value) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ),
      );
    }

    if (_controller.autocompleteSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group suggestions by category
    final groupedSuggestions = <String, List<dynamic>>{};
    for (final suggestion in _controller.autocompleteSuggestions) {
      if (!groupedSuggestions.containsKey(suggestion.category)) {
        groupedSuggestions[suggestion.category] = [];
      }
      groupedSuggestions[suggestion.category]!.add(suggestion);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _getTotalAutocompleteCount(groupedSuggestions),
      itemBuilder: (context, index) {
        return _buildAutocompleteItem(context, index, groupedSuggestions);
      },
    );
  }

  int _getTotalAutocompleteCount(Map<String, List<dynamic>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      count += 1; // Header
      count += entry.value.length; // Items
    }
    return count;
  }

  Widget _buildAutocompleteItem(
      BuildContext context, int index, Map<String, List<dynamic>> grouped) {
    int currentIndex = 0;

    for (final entry in grouped.entries) {
      // Check if this is a header
      if (currentIndex == index) {
        return Padding(
          padding: const EdgeInsets.only(top: 16, bottom: 8),
          child: Text(
            entry.key,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.grey600,
              letterSpacing: 0.5,
            ),
          ),
        );
      }
      currentIndex++;

      // Check if this is one of the items
      for (final suggestion in entry.value) {
        if (currentIndex == index) {
          return _buildSuggestionCard(suggestion);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildSuggestionCard(dynamic suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _handleSuggestionTap(suggestion),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(suggestion.type),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForType(suggestion.type),
                    size: 20,
                    color: _getIconColor(suggestion.type),
                  ),
                ),
                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (suggestion.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          suggestion.subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'specialization':
        return Icons.local_hospital_rounded;
      case 'symptom':
        return Icons.healing_rounded;
      case 'doctor':
        return Icons.person_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case 'specialization':
        return AppColors.primaryGreen.withValues(alpha: 0.1);
      case 'symptom':
        return AppColors.warningOrange.withValues(alpha: 0.1);
      case 'doctor':
        return AppColors.primaryBlue.withValues(alpha: 0.1);
      default:
        return AppColors.grey200;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'specialization':
        return AppColors.primaryGreen;
      case 'symptom':
        return AppColors.warningOrange;
      case 'doctor':
        return AppColors.primaryBlue;
      default:
        return AppColors.grey600;
    }
  }

  Widget _buildInitialLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 48,
            height: 48,
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Searching for doctors...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.grey700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please wait',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey500,
            ),
          ),
        ],
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
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_rounded,
                size: 60,
                color: AppColors.primaryGreen,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Find Your Doctor',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Search by symptoms, specialties, or doctor names to find the right healthcare professional for you',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: AppColors.grey600,
                height: 1.5,
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
