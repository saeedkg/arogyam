import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/consultation/consultation_type.dart';
import '../../../care_discovery/ui/consultation_type_selection_screen.dart';
import '../../../find_doctor/ui/speciality_doctors_screen.dart';
import '../../entities/category_item.dart';

class TopSpecialitiesHorizontal extends StatelessWidget {
  final List<CategoryItem> categories;

  const TopSpecialitiesHorizontal({
    super.key,
    required this.categories,
  });

  @override
  Widget build(BuildContext context) {
    if (categories.isEmpty) {
      return const SizedBox.shrink();
    }

    // Calculate how many items to show (8 items in 2 rows = 4 items per row)
    final itemsToShow = categories.take(8).toList();
    
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4, // 4 items per row
        crossAxisSpacing: 16,
        mainAxisSpacing: 8, // Reduced from 16 to 8
        childAspectRatio: 0.85, // Adjust ratio for proper spacing
      ),
      itemCount: itemsToShow.length,
      itemBuilder: (context, index) {
        final category = itemsToShow[index];
        return _SpecialityCircleItem(category: category);
      },
    );
  }
}

class _SpecialityCircleItem extends StatelessWidget {
  final CategoryItem category;

  const _SpecialityCircleItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCategoryColor(category.name);
    
    return GestureDetector(
      onTap: () {
        // Direct navigation to consultation type selection screen
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
            child: category.svgIcon != null && category.svgIcon!.isNotEmpty
                ? Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: SvgPicture.string(
                        category.svgIcon!,
                        colorFilter: const ColorFilter.mode(
                          Colors.white, // White icon instead of colored
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    _getCategoryIcon(category.name),
                    color: Colors.white, // White icon instead of colored
                    size: 28,
                  ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 70,
            child: Text(
              category.name,
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
