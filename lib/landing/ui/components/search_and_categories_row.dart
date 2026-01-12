import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../care_discovery/ui/care_discovery_screen.dart';
import '../../../care_discovery/ui/search_screen.dart';
import '../../controller/home_controller.dart';
import '../../entities/category_item.dart';

class SearchAndCategoriesRow extends StatelessWidget {
  const SearchAndCategoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final controller = Get.find<HomeController>();
      // Show first 3 categories
      final categories = controller.categories.take(3).toList();
      
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar - takes most of the space
          Expanded(
            child: GestureDetector(
              onTap: () {
                Get.to(() => const SearchScreen());
              },
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 20),
                    const Icon(
                      Icons.search_rounded,
                      color: Colors.grey,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Text(
                        'Search',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Categories - reduced width to give more space to search
          if (categories.isNotEmpty)
            SizedBox(
              width: 160, // Increased slightly to accommodate spacing
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed from spaceEvenly to spaceBetween
                    children: categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return _CategoryCircle(category: category, index: index);
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Changed from spaceEvenly to spaceBetween
                    children: categories.asMap().entries.map((entry) {
                      final index = entry.key;
                      final category = entry.value;
                      return SizedBox(
                        width: 48, // Match the circle width
                        child: Text(
                          _getCategoryDisplayName(category.name, index),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.1,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
        ],
      );
    });
  }

  String _getCategoryDisplayName(String categoryName, int index) {
    // Use fixed names to match the image
    switch (index) {
      case 0:
        return 'Cardiology';
      case 1:
        return 'Pediatrics';
      case 2:
        return 'Mental Health';
      default:
        return categoryName;
    }
  }
}

class _CategoryCircle extends StatelessWidget {
  final CategoryItem category;
  final int index;

  const _CategoryCircle({required this.category, required this.index});

  @override
  Widget build(BuildContext context) {
    final bgColor = _getCategoryColorByIndex(index);
    
    return GestureDetector(
      onTap: () {
        Get.to(() => CareDiscoveryScreen(entry: category.name));
      },
      child: Container(
        width: 48, // Reduced from 56 to 48
        height: 48, // Reduced from 56 to 48
        decoration: BoxDecoration(
          gradient: _getCategoryGradientByIndex(index),
          shape: BoxShape.circle,
        ),
        child: category.svgIcon != null && category.svgIcon!.isNotEmpty
            ? Center(
                child: SizedBox(
                  width: 24, // Reduced from 28 to 24
                  height: 24, // Reduced from 28 to 24
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
                _getCategoryIconByIndex(index),
                color: Colors.white,
                size: 24, // Reduced from 28 to 24
              ),
      ),
    );
  }

  IconData _getCategoryIconByIndex(int index) {
    switch (index) {
      case 0:
        return Icons.person; // Person icon for first category
      case 1:
        return Icons.medical_services; // Medical bag icon for second category
      case 2:
        return Icons.local_hospital; // Medical cross icon for third category
      default:
        return Icons.medical_services;
    }
  }

  Color _getCategoryColorByIndex(int index) {
    // Each category gets a different color variant based on index
    switch (index) {
      case 0:
        return const Color(0xFF4DD0E1); // Cyan variant for first category
      case 1:
        return const Color(0xFFFFC107); // Yellow variant for second category
      case 2:
        return const Color(0xFF9C27B0); // Violet variant for third category
      default:
        return const Color(0xFF4DD0E1); // Default to cyan
    }
  }

  LinearGradient _getCategoryGradientByIndex(int index) {
    // Each category gets a gradient based on index
    switch (index) {
      case 0:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF67E8F9), // Lighter cyan
            Color(0xFF4DD0E1), // Medium cyan
            Color(0xFF26C6DA), // Deeper cyan
          ],
        );
      case 1:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFD54F), // Lighter yellow
            Color(0xFFFFC107), // Medium yellow
            Color(0xFFFFB300), // Deeper yellow
          ],
        );
      case 2:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFBA68C8), // Lighter violet
            Color(0xFF9C27B0), // Medium violet
            Color(0xFF8E24AA), // Deeper violet
          ],
        );
      default:
        return const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF67E8F9), // Default to cyan gradient
            Color(0xFF4DD0E1),
            Color(0xFF26C6DA),
          ],
        );
    }
  }
}
