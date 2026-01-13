import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/ui/app_text.dart';
import '../../../_shared/consultation/consultation_type.dart';
import '../../../common_services/entities/specialization.dart';

class SpecializationGrid extends StatefulWidget {
  final List<Specialization> specializations;
  final AppointmentType? preSelectedAppointmentType;
  final Function(String specialization) onSpecializationSelected;
  
  const SpecializationGrid({
    super.key,
    required this.specializations,
    this.preSelectedAppointmentType,
    required this.onSpecializationSelected,
  });

  @override
  State<SpecializationGrid> createState() => _SpecializationGridState();
}

class _SpecializationGridState extends State<SpecializationGrid> {
  bool _showAll = false;

  @override
  Widget build(BuildContext context) {
    final visibleCount = _showAll
        ? widget.specializations.length
        : (widget.specializations.length > 8 ? 8 : widget.specializations.length);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Enhanced header row with "Categories" and "See all"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Medical Specialties',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
            if (widget.specializations.length > 8)
              GestureDetector(
                onTap: () => setState(() => _showAll = !_showAll),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.2),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    _showAll ? 'See less' : 'See all',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.primaryGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: visibleCount,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, i) {
            final s = widget.specializations[i];
            final bgColor = _getCategoryColor(s.name);

            return GestureDetector(
              onTap: () {
                widget.onSpecializationSelected(s.name);
              },
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: bgColor, // Filled with solid color instead of transparent
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: bgColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: s.svgIcon != null && s.svgIcon!.isNotEmpty
                        ? Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: SvgPicture.string(
                                s.svgIcon!,
                                colorFilter: const ColorFilter.mode(
                                  Colors.white, // White icon instead of colored
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          )
                        : Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child: SvgPicture.asset(
                                _getCategoryIconPath(s.name),
                                colorFilter: const ColorFilter.mode(
                                  Colors.white, // White icon instead of colored
                                  BlendMode.srcIn,
                                ),
                              ),
                            ),
                          ),
                  ),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: 70,
                    child: Text(
                      s.name,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                        height: 1.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
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
        final hash = categoryName.hashCode.abs();
        return _availableColors[hash % _availableColors.length];
    }
  }
}
