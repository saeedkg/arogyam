import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../controller/enhanced_search_controller.dart';
import '../../find_doctor/ui/doctor_detail_info_screen.dart';
import '../entities/search/search_suggestion.dart';
import 'consultation_type_selection_screen.dart';
import 'components/search/popular_searches_widget.dart';
import 'components/search/autocomplete_list_builder.dart';

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
        _controller.onSearchTextChanged(widget.initialQuery!);
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Searching...',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.grey600,
              ),
            ),
          ],
        ),
      );
    }

    if (_controller.autocompleteSuggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group suggestions by category
    final groupedSuggestions = <String, List<SearchSuggestion>>{};
    for (final suggestion in _controller.autocompleteSuggestions) {
      if (!groupedSuggestions.containsKey(suggestion.category)) {
        groupedSuggestions[suggestion.category] = [];
      }
      groupedSuggestions[suggestion.category]!.add(suggestion);
    }

    return AutocompleteListBuilder(
      groupedSuggestions: groupedSuggestions,
      onSuggestionTapped: _handleSuggestionTap,
    );
  }

  Widget _buildInitialLoadingState() {
    return const Center(
      child: CircularProgressIndicator(),
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

  void _handleSuggestionTap(suggestion) {
    if (suggestion.type == 'doctor' && suggestion.slug != null) {
      // Navigate to doctor detail
      Get.to(() => DoctorDetailInfoScreen(doctorId: suggestion.id.toString()));
    } else if (suggestion.type == 'specialization') {
      // Navigate to specialization
      _navigateToSpecialization(suggestion.text);
    } else if (suggestion.type == 'symptom') {
      // Navigate to doctors with symptom search
      _navigateToSymptomSearch(suggestion.text);
    } else {
      // Perform search for other types
      _searchController.text = suggestion.text;
      _controller.onSuggestionTapped(suggestion);
    }
  }

  void _navigateToSymptomSearch(String symptomText) {
    if (!mounted) return;

    if (widget.preSelectedAppointmentType != null) {
      // Appointment type already selected, go directly to doctors
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpecialityDoctorsScreen(
            category: null, // No specific category for symptom search
            appointmentType: widget.preSelectedAppointmentType,
            symptomQuery: symptomText,
          ),
        ),
      );
    } else {
      // Need to select consultation type first
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultationTypeSelectionScreen(
            speciality: null, // No specific speciality for symptom
          ),
        ),
      ).then((result) {
        if (!mounted) return;
        if (result != null && result is AppointmentType) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialityDoctorsScreen(
                category: null, // No specific category for symptom search
                appointmentType: result,
                symptomQuery: symptomText,
              ),
            ),
          );
        }
      });
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
