import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/routing/routing.dart';
import '../controller/doctors_controller.dart';
import '../entities/doctor_list_item.dart';
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
  String _selectedSortOption = 'Recommended';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.setActiveFilter(widget.category);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
              ...['Recommended', 'Experience', 'Rating', 'Availability', 'Price']
                  .map((option) => ListTile(
                title: Text(option),
                trailing: _selectedSortOption == option
                    ? Icon(Icons.check, color: AppColors.primaryGreen)
                    : null,
                onTap: () {
                  setState(() {
                    _selectedSortOption = option;
                  });
                  Get.back();
                },
              ))
                  .toList(),
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
              '${c.filtered.length} doctors available',
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
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.zero,
                    children: const [
                      _FilterChip(label: 'All', isSelected: true),
                      _FilterChip(label: 'Available Today'),
                      _FilterChip(label: 'Near Me'),
                      _FilterChip(label: 'Top Rated'),
                      _FilterChip(label: 'Video Consult'),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 🩺 Doctors List Section
          Expanded(
            child: Obx(() {
              if (c.isLoading.value) {
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

              if (c.filtered.isEmpty) {
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
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                        child: const Text('Clear Search'),
                      ),
                    ],
                  ),
                );
              }

              return ListView.separated(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                itemCount: c.filtered.length,
                separatorBuilder: (_, __) => const SizedBox(height: 16),
                itemBuilder: (_, i) {
                  final d = c.filtered[i];
                  return DoctorCard(doctor: d);
                },
              );
            }),
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
  const _FilterChip({required this.label, this.isSelected = false});

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
        checkmarkColor: Colors.white, // ✅ white tick when selected


        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) {},
      ),
    );
  }
}
