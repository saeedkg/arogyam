import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../booking/ui/doctor_booking_screen.dart';
import '../controller/doctors_controller.dart';
import '../entities/doctor_filter.dart';
import 'components/doctor_card.dart';

class SpecialityDoctorsScreen extends StatefulWidget {
  final String category;
  final AppointmentType? appointmentType;
  final String? symptomQuery;
  
  const SpecialityDoctorsScreen({
    super.key,
    required this.category,
    this.appointmentType,
    this.symptomQuery,
  });

  @override
  State<SpecialityDoctorsScreen> createState() => _SpecialityDoctorsScreenState();
}

class _SpecialityDoctorsScreenState extends State<SpecialityDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final c = Get.put(DoctorsController());
  DoctorSortBy _selectedSortOption = DoctorSortBy.recommended;
  Timer? _searchDebounceTimer;
  
  // Simplified appointment filter options
  AppointmentFilterType _selectedAppointmentFilter = AppointmentFilterType.video;

  void _onDoctorSelected(String doctorId, Map<String, dynamic> doctorData) {
    // Navigate directly to doctor booking screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DoctorBookingScreen(doctorId: doctorId),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // Reset the controller to clear any previous state
    c.api.reset();
    c.doctors.clear();
    c.query.value = ''; // Clear any previous search query
    
    // Set symptom query if provided
    if (widget.symptomQuery != null && widget.symptomQuery!.isNotEmpty) {
      _searchController.text = widget.symptomQuery!;
      c.query.value = widget.symptomQuery!;
    }
    
    // Auto-select filter based on appointmentType parameter
    if (widget.appointmentType != null) {
      switch (widget.appointmentType!) {
        case AppointmentType.video:
          _selectedAppointmentFilter = AppointmentFilterType.video;
          break;
        case AppointmentType.clinic:
          _selectedAppointmentFilter = AppointmentFilterType.physical;
          break;
      }
    }
    
    // Set the specialization filter but don't trigger fetch yet
    c.activeFilter.value = widget.category;
    
    // Apply all filters together in a single post-frame callback
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Wait for specializations to load if needed
      _waitForSpecializationsAndApplyFilters();
    });
  }
  
  void _waitForSpecializationsAndApplyFilters() async {
    // Wait for specializations to load
    while (c.isLoadingSpecializations.value) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    
    // Now apply all filters at once
    if (widget.appointmentType != null) {
      switch (widget.appointmentType!) {
        case AppointmentType.video:
          c.currentFilter.value = c.currentFilter.value.copyWith(
            specialization: widget.category != 'All' ? widget.category : null,
            quickFilters: {DoctorQuickFilter.videoConsult},
          );
          break;
        case AppointmentType.clinic:
          c.currentFilter.value = c.currentFilter.value.copyWith(
            specialization: widget.category != 'All' ? widget.category : null,
            quickFilters: {DoctorQuickFilter.physicalConsult},
          );
          break;
      }
    } else {
      // No appointment type, just set specialization
      c.currentFilter.value = c.currentFilter.value.copyWith(
        specialization: widget.category != 'All' ? widget.category : null,
      );
    }
    
    // Make single API call with all filters applied
    c.fetchInitialDoctors();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchDebounceTimer?.cancel();
    super.dispose();
  }
  
  void _onSearchChanged(String value) {
    _searchDebounceTimer?.cancel();
    _searchDebounceTimer = Timer(const Duration(milliseconds: 800), () {
      c.query.value = value;
      c.fetchInitialDoctors();
    });
  }

  Widget _buildDoctorsList(DoctorsController c) {
    // Show loading state when initially loading (no doctors yet and loading)
    if (c.isLoading.value && c.doctors.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading doctors...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show loading state when specializations are still loading
    if (c.isLoadingSpecializations.value) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading specializations...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Show error state when there's an error and no doctors
    if (c.errorMessage.value.isNotEmpty && c.doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                c.errorMessage.value.toLowerCase().contains('internet')
                    ? Icons.wifi_off
                    : Icons.error_outline,
                size: 64,
                color: Colors.grey.shade300,
              ),
              const SizedBox(height: 16),
              Text(
                c.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => c.fetchInitialDoctors(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryGreen,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Show "No doctors found" only when:
    // 1. Not loading AND
    // 2. No error AND  
    // 3. No doctors available AND
    // 4. Initial load has completed (not in loading specializations state)
    if (!c.isLoading.value && 
        c.errorMessage.value.isEmpty && 
        !c.hasDoctors && 
        !c.isLoadingSpecializations.value) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.medical_services_outlined,
                size: 80, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'No doctors found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try adjusting your search or filters',
              style: TextStyle(
                  fontSize: 14, color: Colors.grey.shade500),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                c.query.value = '';
                c.fetchInitialDoctors();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Clear Search'),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await c.fetchInitialDoctors();
      },
      color: Colors.white,
      backgroundColor: AppColors.primaryGreen,
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          if (!c.isLoading.value &&
              c.didReachListEnd == false &&
              scrollInfo.metrics.pixels >= scrollInfo.metrics.maxScrollExtent - 100) {
            c.fetchMoreDoctors();
          }
          return false;
        },
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          itemCount: c.doctors.length + (c.didReachListEnd ? 0 : 1),
          itemBuilder: (context, index) {
            if (index == c.doctors.length) {
              // Show loading indicator at the end
              if (!c.didReachListEnd) {
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 16),
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                );
              }
              return const SizedBox.shrink();
            }
            final d = c.doctors[index];
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DoctorCard(
                doctor: d,
                onDoctorSelected: _onDoctorSelected,
                appointmentType: _selectedAppointmentFilter,
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSortOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sort By',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),
              ...DoctorSortBy.values.map((option) => ListTile(
                title: Text(option.displayName),
                trailing: _selectedSortOption == option
                    ? Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedSortOption = option;
                  });
                  c.setSortBy(option);
                  Get.back();
                },
              )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: Get.back,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.category,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Obx(() => Text(
              '${c.doctors.length} doctors available',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            )),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _showSortOptions,
            icon: Icon(Icons.sort_rounded, color: AppColors.primaryGreen),
          ),
        ],
      ),

      // 🧭 Body
      body: Column(
        children: [
          // 🔍 Search + Filter Section
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(width: 0.4, color: Color(0xFFE5E7EB)),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Search Box
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search doctors, specialization or clinic...',
                      hintStyle:
                      TextStyle(color: Colors.grey.shade500, fontSize: 14),
                      prefixIcon:
                      const Icon(Icons.search_rounded, color: Colors.grey),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                        icon: const Icon(Icons.close_rounded,
                            color: Colors.grey, size: 20),
                        onPressed: () {
                          _searchController.clear();
                          c.query.value = '';
                          c.fetchInitialDoctors();
                        },
                      )
                          : null,
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 14, horizontal: 16),
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                // Professional Toggle Switch for Appointment Type
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_selectedAppointmentFilter != AppointmentFilterType.video) {
                              setState(() {
                                _selectedAppointmentFilter = AppointmentFilterType.video;
                              });
                              // Apply video consultation filter in one operation
                              c.currentFilter.value = c.currentFilter.value.copyWith(
                                specialization: widget.category != 'All' ? widget.category : null,
                                quickFilters: {DoctorQuickFilter.videoConsult},
                              );
                              c.fetchInitialDoctors();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _selectedAppointmentFilter == AppointmentFilterType.video
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedAppointmentFilter == AppointmentFilterType.video
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.videocam_rounded,
                                    size: 18,
                                    color: _selectedAppointmentFilter == AppointmentFilterType.video
                                        ? AppColors.primaryGreen
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Video',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _selectedAppointmentFilter == AppointmentFilterType.video
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: _selectedAppointmentFilter == AppointmentFilterType.video
                                          ? AppColors.primaryGreen
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_selectedAppointmentFilter != AppointmentFilterType.physical) {
                              setState(() {
                                _selectedAppointmentFilter = AppointmentFilterType.physical;
                              });
                              // Apply physical appointment filter in one operation
                              c.currentFilter.value = c.currentFilter.value.copyWith(
                                specialization: widget.category != 'All' ? widget.category : null,
                                quickFilters: {DoctorQuickFilter.physicalConsult},
                              );
                              c.fetchInitialDoctors();
                            }
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: _selectedAppointmentFilter == AppointmentFilterType.physical
                                  ? Colors.white
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: _selectedAppointmentFilter == AppointmentFilterType.physical
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : [],
                            ),
                            child: Center(
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.local_hospital_rounded,
                                    size: 18,
                                    color: _selectedAppointmentFilter == AppointmentFilterType.physical
                                        ? AppColors.primaryGreen
                                        : Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Physical',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: _selectedAppointmentFilter == AppointmentFilterType.physical
                                          ? FontWeight.w600
                                          : FontWeight.w500,
                                      color: _selectedAppointmentFilter == AppointmentFilterType.physical
                                          ? AppColors.primaryGreen
                                          : Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🩺 Doctors List Section
          Expanded(
            child: Obx(() => _buildDoctorsList(c)),
          ),
        ],
      ),
    );
  }
}

// Simplified appointment filter types
enum AppointmentFilterType {
  video,
  physical,
}

// 🔘 Simplified AppointmentFilterChip Widget
class _AppointmentFilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _AppointmentFilterChip({
    required this.label,
    this.isSelected = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade700,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        selected: isSelected,
        backgroundColor: Colors.grey.shade100,
        selectedColor: AppColors.primaryGreen,
        checkmarkColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => onTap(),
      ),
    );
  }
}
