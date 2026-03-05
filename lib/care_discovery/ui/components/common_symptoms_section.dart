import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../entities/common_symptom.dart';

class CommonSymptomsSection extends StatelessWidget {
  final List<CommonSymptom> symptoms;
  final Function(CommonSymptom symptom) onSymptomSelected;

  const CommonSymptomsSection({
    super.key,
    required this.symptoms,
    required this.onSymptomSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            'Common Symptoms',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.black87,
              letterSpacing: -0.3,
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Horizontal scrollable list
        SizedBox(
          height: 160,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: symptoms.length,
            itemBuilder: (context, index) {
              final symptom = symptoms[index];
              return Padding(
                padding: EdgeInsets.only(
                  right: index < symptoms.length - 1 ? 12 : 0,
                ),
                child: _buildSymptomCard(symptom),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomCard(CommonSymptom symptom) {
    return GestureDetector(
      onTap: () => onSymptomSelected(symptom),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(16),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: symptom.backgroundColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: symptom.iconColor.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: SvgPicture.asset(
                    symptom.iconPath,
                    colorFilter: ColorFilter.mode(
                      symptom.iconColor,
                      BlendMode.srcIn,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Symptom name
            Text(
              symptom.name,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
                height: 1.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),

            // Description
            Expanded(
              child: Text(
                symptom.description,
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey600,
                  fontWeight: FontWeight.w400,
                  height: 1.3,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
