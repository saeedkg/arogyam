import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/ui/app_text.dart';
import '../../../common_services/entities/specialization.dart';

class SpecializationGrid extends StatelessWidget {
  final List<Specialization> specializations;
  const SpecializationGrid({super.key, required this.specializations});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.titleLarge('Categories'),
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
          itemCount: specializations.length,
          itemBuilder: (context, i) {
            final s = specializations[i];
            final bgColor = _getCategoryColor(s.name);

            return Column(
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
                              SvgPicture.asset(
                                _getCategoryIconPath(s.name),
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
                  s.name,
                  maxLines: 1,
                ),
              ],
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
      case 'general medicine':
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
      case 'general medicine':
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
        return Colors.grey;
    }
  }
}
