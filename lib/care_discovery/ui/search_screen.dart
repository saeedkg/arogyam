import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/routing/routing.dart';
import '../controller/search_controller.dart';
import '../../common_services/entities/specialization.dart';
import '../../find_doctor/entities/doctor_list_item.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late final CareSearchController _controller;
  
  @override
  void initState() {
    super.initState();
    _controller = Get.put(CareSearchController());
    // Auto-focus the search field when screen opens
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(FocusNode());
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch(String query) {
    _controller.performSearch(query);
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
                onChanged: _performSearch,
                decoration: InputDecoration(
                  hintText: 'Search doctors or specialties',
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
                    AppNavigation.toDoctors();
                  }
                },
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Search Results
          Expanded(
            child: _buildSearchResults(),
          ),
        ],
      )),
    );
  }

  Widget _buildSearchResults() {
    if (_controller.isLoading.value) {
      return _buildLoadingState();
    }
    
    if (_controller.showEmptyState) {
      return _buildEmptyState();
    }
    
    if (_controller.showNoResults) {
      return _buildNoResultsState();
    }
    
    if (_controller.showResults) {
      return _buildResultsList();
    }
    
    return _buildEmptyState();
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.only(top: 100),
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

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.only(top: 100),
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
              'Search for doctors or specialties',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.grey700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Type in the search box above to find what you\'re looking for',
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.only(top: 100),
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
              'Try searching with different keywords or browse all doctors',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => AppNavigation.toDoctors(),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                elevation: 0,
              ),
              child: const Text(
                'Browse All Doctors',
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

  Widget _buildResultsList() {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Specializations Section
          if (_controller.filteredSpecializations.isNotEmpty) ...[
            _buildSectionHeader('Specialties', _controller.filteredSpecializations.length),
            const SizedBox(height: 16),
            ..._controller.filteredSpecializations.map((spec) => _buildSpecializationItem(spec)),
            const SizedBox(height: 32),
          ],
          
          // Doctors Section
          if (_controller.filteredDoctors.isNotEmpty) ...[
            _buildSectionHeader('Doctors', _controller.filteredDoctors.length),
            const SizedBox(height: 16),
            ..._controller.filteredDoctors.map((doctor) => _buildDoctorItem(doctor)),
          ],
          
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
      child: Row(
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
          Text(
            title,
            style: const TextStyle(
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
      ),
    );
  }

  Widget _buildSpecializationItem(Specialization specialization) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => AppNavigation.toDoctors(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Professional Icon Container
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Content - Two Rows Only
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Row: Specialization Name and Badge
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              specialization.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Specialty',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Second Row: Description and Arrow
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Find specialized doctors',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.grey400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorItem(DoctorListItem doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => AppNavigation.toDoctors(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Doctor Avatar with Status
                Stack(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: AppColors.grey200,
                          width: 2,
                        ),
                        image: DecorationImage(
                          image: NetworkImage(doctor.imageUrl),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    if (doctor.isOnline)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 16,
                          height: 16,
                          decoration: BoxDecoration(
                            color: AppColors.successGreen,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 16),
                
                // Doctor Info - Two Rows Only
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // First Row: Name and Fee
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor.name,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Fee
                          Text(
                            '₹${doctor.consultationFee}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryGreen,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Second Row: Specialization and Status Badges
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              doctor.specialization,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          
                          // Available Today Badge
                          if (doctor.availableToday)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Available',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ),
                          
                          const SizedBox(width: 8),
                          
                          // Arrow
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: AppColors.grey400,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}