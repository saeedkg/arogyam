import 'package:flutter/material.dart';
import '../../../_shared/ui/app_colors.dart';

class MonsoonCareTipsCard extends StatelessWidget {
  const MonsoonCareTipsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // TODO: Navigate to tips detail
        },
        child: Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              // Circular image section
              Padding(
                padding: const EdgeInsets.all(6),
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryGreen.withOpacity(0.1),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://images.unsplash.com/photo-1559839734-2b71ea197ec2?w=400',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.transparent,
                        ),
                        child: Center(
                          child: Icon(
                            Icons.health_and_safety_rounded,
                            color: AppColors.primaryGreen,
                            size: 40,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              // Content section
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Monsoon Care Tips',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Lorem ip sum dolor sit amet turtearatinrion selild Ireemet',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.grey.shade600,
                          height: 1.2,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ),
              // Arrow icon
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 10,
                    color: Colors.grey.shade400,
                  ),
                ),
              ),
            ],
          ),
        ),
      );

  }
}
