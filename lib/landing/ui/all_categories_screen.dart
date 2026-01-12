import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../_shared/ui/app_colors.dart';
import '../../_shared/ui/app_text.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../care_discovery/ui/care_discovery_screen.dart';
import '../../care_discovery/ui/consultation_type_selection_screen.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
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
                  
                  // Categories Grid - Same as Dashboard TopSpecialitiesHorizontal
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 4 items per row like dashboard
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 8, // Same as dashboard
                      childAspectRatio: 0.85, // Same as dashboard
                    ),
                    itemCount: _allCategories.length,
                    itemBuilder: (context, index) {
                      final category = _allCategories[index];
                      return _CategoryCircleItem(category: category);
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

class _CategoryCircleItem extends StatelessWidget {
  final CategoryItem category;

  const _CategoryCircleItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCategoryColor(category.name);
    
    return GestureDetector(
      onTap: () {
        // Direct navigation to consultation type selection screen (same as dashboard)
        Navigator.push<AppointmentType>(
          context,
          MaterialPageRoute(
            builder: (context) => ConsultationTypeSelectionScreen(
              speciality: category.name,
            ),
          ),
        ).then((appointmentType) {
          // Handle the returned appointment type and navigate to doctor list
          if (appointmentType != null) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SpecialityDoctorsScreen(
                  category: category.name,
                  appointmentType: appointmentType,
                ),
              ),
            );
          }
        });
      },
      child: Column(
        children: [
          Container(
            width: 56, // Same as dashboard
            height: 56, // Same as dashboard
            decoration: BoxDecoration(
              color: bgColor.withOpacity(0.15), // Same as dashboard
              shape: BoxShape.circle,
              border: Border.all(
                color: bgColor.withOpacity(0.3), // Same as dashboard
                width: 1.5,
              ),
            ),
            child: category.svgIcon != null && category.svgIcon!.isNotEmpty
                ? Center(
                    child: SizedBox(
                      width: 28, // Same as dashboard
                      height: 28, // Same as dashboard
                      child: SvgPicture.string(
                        category.svgIcon!,
                        colorFilter: ColorFilter.mode(
                          bgColor,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    _getCategoryIcon(category.name),
                    color: bgColor,
                    size: 28, // Same as dashboard
                  ),
          ),
          const SizedBox(height: 6), // Same as dashboard
          SizedBox(
            width: 70, // Same as dashboard
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11, // Same as dashboard
                fontWeight: FontWeight.w500, // Same as dashboard
                color: Colors.black87, // Same as dashboard
                height: 1.2,
              ),
              maxLines: 1, // Same as dashboard
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final lowerName = categoryName.toLowerCase();
    if (lowerName.contains('cardio')) {
      return Icons.favorite_rounded;
    } else if (lowerName.contains('pediatr') || lowerName.contains('kids')) {
      return Icons.child_care_rounded;
    } else if (lowerName.contains('mental') || lowerName.contains('psych')) {
      return Icons.psychology_rounded;
    } else if (lowerName.contains('neuro')) {
      return Icons.memory_rounded;
    } else if (lowerName.contains('gastro')) {
      return Icons.restaurant_rounded;
    }
    return Icons.medical_services_rounded;
  }

  // Helper method to get color based on category name (same as dashboard)
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
        final colors = [
          AppColors.peach,
          AppColors.roseDust,
          AppColors.sageGreen,
          AppColors.blueBell,
          AppColors.mediumSkyBlue,
          AppColors.teal,
          AppColors.blush,
          AppColors.deepPurple,
        ];
        return colors[hash % colors.length];
    }
  }
}