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
    
    return Wrap(
      spacing: 16, // Horizontal spacing between items
      runSpacing: 16, // Vertical spacing between rows
      alignment: WrapAlignment.spaceBetween, // Distribute items evenly
      children: itemsToShow.map((category) {
        return SizedBox(
          width: (MediaQuery.of(context).size.width - 40 - 48) / 4, // Calculate width: (screen - padding - spacing) / 4 items
          child: _SpecialityCircleItem(category: category),
        );
      }).toList(),
    );
  }
}

class _SpecialityCircleItem extends StatelessWidget {
  final CategoryItem category;

  const _SpecialityCircleItem({required this.category});

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCategoryColor(category.name);
    
    // Get screen width for responsive sizing
    final screenWidth = MediaQuery.of(context).size.width;
    
    // Calculate responsive sizes based on screen width
    final circleSize = screenWidth > 400 ? 64.0 : (screenWidth > 350 ? 58.0 : 52.0);
    final iconSize = screenWidth > 400 ? 32.0 : (screenWidth > 350 ? 30.0 : 26.0);
    final fontSize = screenWidth > 400 ? 12.0 : (screenWidth > 350 ? 11.5 : 10.5);
    final spacing = screenWidth > 400 ? 8.0 : 6.0;
    final textWidth = screenWidth > 400 ? 80.0 : (screenWidth > 350 ? 75.0 : 65.0);
    
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
            width: circleSize,
            height: circleSize,
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
                      width: iconSize,
                      height: iconSize,
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
                    size: iconSize,
                  ),
          ),
          SizedBox(height: spacing),
          SizedBox(
            width: textWidth,
            child: Text(
              category.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: fontSize,
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
