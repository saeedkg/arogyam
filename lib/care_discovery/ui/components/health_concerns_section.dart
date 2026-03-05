import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../entities/health_concern.dart';

class HealthConcernsSection extends StatelessWidget {
  final List<HealthConcern> healthConcerns;
  final Function(HealthConcern concern) onConcernSelected;

  const HealthConcernsSection({
    super.key,
    required this.healthConcerns,
    required this.onConcernSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Text(
          'Browse by Health Concern',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),

        // Grid layout
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: healthConcerns.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final concern = healthConcerns[index];
            return _buildConcernCard(concern);
          },
        ),
      ],
    );
  }

  Widget _buildConcernCard(HealthConcern concern) {
    return GestureDetector(
      onTap: () => onConcernSelected(concern),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.grey200,
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container with gradient
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    concern.primaryColor,
                    concern.primaryColor.withValues(alpha: 0.7),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: concern.primaryColor.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 18,
                  height: 18,
                  child: SvgPicture.asset(
                    concern.iconPath,
                    colorFilter: const ColorFilter.mode(
                      Colors.white,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Concern name
            Flexible(
              child: Text(
                concern.name,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 2),

            // Subtitle
            Text(
              concern.subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10,
                color: AppColors.grey600,
                fontWeight: FontWeight.w400,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
