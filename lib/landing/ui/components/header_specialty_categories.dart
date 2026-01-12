import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../care_discovery/ui/care_discovery_screen.dart';
import '../../controller/home_controller.dart';
import '../../entities/category_item.dart';

class HeaderSpecialtyCategories extends StatelessWidget {
  const HeaderSpecialtyCategories({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<HomeController>();
      // Show first 3 categories in header
      final categories = controller.categories.take(3).toList();
      
      if (categories.isEmpty) {
        return const SizedBox.shrink();
      }
      
      return SizedBox(
        height: 80,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: categories.length,
          separatorBuilder: (_, __) => const SizedBox(width: 16),
          itemBuilder: (context, index) {
            final category = categories[index];
            return _HeaderSpecialtyItem(category: category);
          },
        ),
      );
    });
  }
}

class _HeaderSpecialtyItem extends StatelessWidget {
  final CategoryItem category;

  const _HeaderSpecialtyItem({required this.category});

  @override
  Widget build(BuildContext context) {
    // Get color based on category name
    final color = _getCategoryColor(category.name);
    
    return GestureDetector(
      onTap: () {
        Get.to(() => CareDiscoveryScreen(entry: category.name));
      },
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            child: category.svgIcon != null && category.svgIcon!.isNotEmpty
                ? Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: SvgPicture.string(
                        category.svgIcon!,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  )
                : Icon(
                    _getCategoryIcon(category.name),
                    color: Colors.white,
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
                color: Colors.white,
                height: 1.2,
              ),
              maxLines: 2,
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
    }
    return Icons.medical_services_rounded;
  }

  Color _getCategoryColor(String categoryName) {
    // Not used in header but kept for consistency
    return AppColors.primaryGreen;
  }
}
