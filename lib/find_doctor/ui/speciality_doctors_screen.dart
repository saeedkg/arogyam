import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/doctors_controller.dart';
import '../entities/doctor_filter.dart';
import 'components/doctor_card.dart';

class SpecialityDoctorsScreen extends StatefulWidget {
  final String category;
  const SpecialityDoctorsScreen({super.key, required this.category});

  @override
  State<SpecialityDoctorsScreen> createState() => _SpecialityDoctorsScreenState();
}

class _SpecialityDoctorsScreenState extends State<SpecialityDoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final c = Get.put(DoctorsController());
  DoctorSortBy _selectedSortOption = DoctorSortBy.recommended;

  @override
  void initState() {
    super.initState();
    // Reset the controller to clear any previous state
    c.api.reset();
    c.doctors.clear();
    c.query.value = ''; // Clear any previous search query
    
    // Set filter immediately - this will trigger fetchInitialDoctors
    // If specializations are already loaded, it will trigger immediately
    // If not, it will be stored as _pendingFilter and applied when specializations load
    c.setActiveFilter(widget.category);
    
    // Ensure fetch happens after frame is built
    // This handles cases where specializations are already loaded but filter wasn't applied yet
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // If specializations are loaded, filter is set, but no doctors - fetch now
      if (!c.isLoadingSpecializations.value && 
          c.filters.contains(widget.category) && 
          c.activeFilter.value == widget.category &&
          c.doctors.isEmpty &&
          !c.isLoading.value) {
        c.fetchInitialDoctors();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Widget _buildDoctorsList(DoctorsController c) {
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

    if (!c.hasDoctors) {
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
              child: DoctorCard(doctor: d),
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
                    onChanged: (v) => c.query.value = v,
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

                // Filter Chips Row
                SizedBox(
                  height: 42,
                  child: Obx(() => ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    children: [
                      _FilterChip(
                        label: 'All',
                        isSelected: c.currentFilter.value.quickFilters.isEmpty,
                        onTap: () => c.clearQuickFilters(),
                      ),
                      ...DoctorQuickFilter.values.map((filter) => _FilterChip(
                        label: filter.displayName,
                        isSelected: c.currentFilter.value.hasQuickFilter(filter),
                        onTap: () => c.toggleQuickFilter(filter),
                      )),
                    ],
                  )),
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

// 🔘 FilterChip Widget
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _FilterChip({
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
