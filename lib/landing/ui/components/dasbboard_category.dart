import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/ui/app_text.dart';
import '../../../_shared/consultation/consultation_type.dart';
import '../../../care_discovery/ui/consultation_type_selection_screen.dart';
import '../../../find_doctor/ui/speciality_doctors_screen.dart';
import '../../entities/category_item.dart';
import '../all_categories_screen.dart';

class CategoriesGrid extends StatelessWidget {
  final List<CategoryItem> categories;
  const CategoriesGrid({super.key, required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionHeader(
          title: 'Categories',
          onSeeAllPressed: () {
            // Navigate to full categories list
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AllCategoriesScreen(categories: categories),
              ),
            );
          },
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: .90,
          ),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final c = categories[i];
            final bgColor = _getCategoryColor(c.name);

            return GestureDetector(
              onTap: () {
                // Direct navigation to consultation type selection screen
                Navigator.push<AppointmentType>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ConsultationTypeSelectionScreen(
                      speciality: c.name,
                    ),
                  ),
                ).then((appointmentType) {
                  // Handle the returned appointment type and navigate to doctor list
                  if (appointmentType != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => SpecialityDoctorsScreen(
                          category: c.name,
                          appointmentType: appointmentType,
                        ),
                      ),
                    );
                  }
                  // If cancelled, stay on dashboard
                });
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
      ],
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
class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;
  
  const _SectionHeader({
    required this.title,
    this.onSeeAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.titleLarge(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        const Spacer(),
        TextButton(
          onPressed: onSeeAllPressed,
          child: const Text('See all'),
        ),
      ],
    );
  }
}