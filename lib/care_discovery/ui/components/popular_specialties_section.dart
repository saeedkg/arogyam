import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/consultation/consultation_type.dart';
import '../../entities/popular_specialty.dart';

class PopularSpecialtiesSection extends StatelessWidget {
  final List<PopularSpecialty> specialties;
  final AppointmentType? preSelectedAppointmentType;
  final Function(String specialization) onSpecializationSelected;
  final VoidCallback onViewAllTapped;

  const PopularSpecialtiesSection({
    super.key,
    required this.specialties,
    this.preSelectedAppointmentType,
    required this.onSpecializationSelected,
    required this.onViewAllTapped,
  });

  @override
  Widget build(BuildContext context) {
    // Take only first 8 items
    final displaySpecialties = specialties.take(8).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header with "View All" button
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Popular Specialties',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Colors.black87,
                letterSpacing: -0.3,
              ),
            ),
            GestureDetector(
              onTap: onViewAllTapped,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryGreen.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primaryGreen.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Text(
                  'View All',
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

        // Grid of specialty cards
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: displaySpecialties.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4,
            crossAxisSpacing: 16,
            mainAxisSpacing: 8,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final specialty = displaySpecialties[index];
            return _buildSpecialtyCard(specialty);
          },
        ),
      ],
    );
  }

  Widget _buildSpecialtyCard(PopularSpecialty specialty) {
    return GestureDetector(
      onTap: () => onSpecializationSelected(specialty.name),
      child: Column(
        children: [
          // Circle container with icon
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: specialty.backgroundColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: specialty.backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: specialty.svgIcon != null && specialty.svgIcon!.isNotEmpty
                ? Center(
                    child: SizedBox(
                      width: 28,
                      height: 28,
                      child: SvgPicture.string(
                        specialty.svgIcon!,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
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
                        specialty.iconPath,
                        colorFilter: const ColorFilter.mode(
                          Colors.white,
                          BlendMode.srcIn,
                        ),
                      ),
                    ),
                  ),
          ),
          const SizedBox(height: 6),
          
          // Specialty name
          SizedBox(
            width: 70,
            child: Text(
              specialty.name,
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
}
