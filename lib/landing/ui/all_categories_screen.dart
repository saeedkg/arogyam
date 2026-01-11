import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../_shared/ui/app_colors.dart';
import '../../_shared/ui/app_text.dart';
import '../../_shared/booking_flow/booking_flow_manager.dart';
import '../../common_services/services/specialization_service.dart';
import '../../common_services/entities/specialization.dart';
import '../entities/category_item.dart';

class AllCategoriesScreen extends StatefulWidget {
  final List<CategoryItem> categories;
  
  const AllCategoriesScreen({
    super.key,
    required this.categories,
  });

  @override
  State<AllCategoriesScreen> createState() => _AllCategoriesScreenState();
}

class _AllCategoriesScreenState extends State<AllCategoriesScreen> {
  final SpecializationService _specializationService = SpecializationService();
  List<CategoryItem> _allCategories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAllCategories();
  }

  Future<void> _loadAllCategories() async {
    try {
      final specializations = await _specializationService.fetchSpecializations();
      setState(() {
        _allCategories = specializations.map((s) => CategoryItem(
          id: s.id.toString(),
          name: s.name,
          svgIcon: s.svgIcon,
        )).toList();
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to the categories passed from dashboard
      setState(() {
        _allCategories = widget.categories;
        _isLoading = false;
      });
    }
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
          'All Categories',
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
      body: _isLoading 
          ? Center(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 16,
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
                      'Loading all categories...',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: -2,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen,
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: const Icon(
                            Icons.medical_services_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Medical Specialties',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_allCategories.length} specialties available',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Categories Grid - Same as Dashboard
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: .90,
                    ),
                    itemCount: _allCategories.length,
                    itemBuilder: (context, index) {
                      final c = _allCategories[index];
                      final bgColor = _getCategoryColor(c.name);

                      return GestureDetector(
                        onTap: () {
                          // Navigate using new BookingFlowManager with specializationFilter entry
                          // This skips CareDiscoveryScreen since we already know the specialization
                          BookingFlowManager.instance.startBookingFlow(
                            entry: BookingFlowEntry.specializationFilter,
                            selectedSpecialization: c.name,
                          );
                        },
                        child: Column(
                          children: [
                            Expanded(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(24),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(alpha: 0.05),
                                      blurRadius: 10,
                                      offset: const Offset(0, 6),
                                    ),
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    // 🌙 Glossy ellipse overlay (top-left)
                                    Positioned(
                                      top: -90,
                                      left: -90,
                                      child: Container(
                                        height: 120,
                                        width: 120,
                                        decoration: BoxDecoration(
                                          color: Colors.white.withValues(alpha: 0.15),
                                          borderRadius: BorderRadius.circular(25),
                                        ),
                                      ),
                                    ),
                              
                                    // 🌿 Icon and Text
                                    Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          c.svgIcon != null && c.svgIcon!.isNotEmpty
                                              ? SvgPicture.string(
                                                  c.svgIcon!,
                                                  height: 36,
                                                  colorFilter: const ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                                )
                                              : SvgPicture.asset(
                                                  _getCategoryIconPath(c.name),
                                                  height: 36,
                                                  colorFilter: const ColorFilter.mode(
                                                    Colors.white,
                                                    BlendMode.srcIn,
                                                  ),
                                                ),
                                          const SizedBox(height: 8),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 6),
                            AppText.label(
                              c.name,
                              maxLines: 1,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  
                  const SizedBox(height: 32),
                ],
              ),
            ),
    );
  }

  // Helper method to get icon path based on category name
  String _getCategoryIconPath(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'dentistry':
        return 'assets/icon_svg/ic_dentel.svg';
      case 'cardiology':
      case 'cardiolo...':
        return 'assets/icon_svg/ic_cardio.svg';
      case 'pulmonology':
      case 'pulmono...':
        return 'assets/icon_svg/ic_pulmanology.svg';
      case 'general':
        return 'assets/icon_svg/ic_general.svg';
      case 'neurology':
        return 'assets/icon_svg/ic_neurology.svg';
      case 'gastroenterology':
      case 'gastroen':
        return 'assets/icon_svg/ic_gastrom.svg';
      case 'laboratory':
        return 'assets/icon_svg/ic_laboratory.svg';
      case 'vaccination':
      case 'vaccinat...':
        return 'assets/icon_svg/ic_vaccin.svg';
      default:
        return 'assets/icon_svg/ic_general.svg';
    }
  }

  // List of available colors for categories
  static const List<Color> _availableColors = [
    AppColors.peach,
    AppColors.roseDust,
    AppColors.sageGreen,
    AppColors.blueBell,
    AppColors.mediumSkyBlue,
    AppColors.teal,
    AppColors.blush,
    AppColors.deepPurple,
  ];

  // Helper method to get color based on category name
  Color _getCategoryColor(String categoryName) {
    switch (categoryName.toLowerCase()) {
      case 'dentistry':
        return AppColors.peach;
      case 'cardiology':
      case 'cardiolo...':
        return AppColors.roseDust;
      case 'pulmonology':
      case 'pulmono...':
        return AppColors.sageGreen;
      case 'general':
        return AppColors.blueBell;
      case 'neurology':
        return AppColors.mediumSkyBlue;
      case 'gastroenterology':
      case 'gastroen':
        return AppColors.teal;
      case 'laboratory':
        return AppColors.blush;
      case 'vaccination':
      case 'vaccinat...':
        return AppColors.deepPurple;
      default:
        final hash = categoryName.hashCode.abs();
        return _availableColors[hash % _availableColors.length];
    }
  }
}