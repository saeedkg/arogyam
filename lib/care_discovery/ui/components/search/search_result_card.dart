import 'package:flutter/material.dart';
import '../../../../_shared/ui/app_colors.dart';
import '../../../entities/search_result_item.dart';

class SearchResultCard extends StatelessWidget {
  final SearchResultItem result;
  final VoidCallback onTap;

  const SearchResultCard({
    super.key,
    required this.result,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Avatar with Status
                _buildAvatar(),
                const SizedBox(width: 16),

                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Name and Fee Row
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              result.name,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (result.consultationFee != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '₹${result.consultationFee}',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Specialization
                      if (result.specializations.isNotEmpty)
                        Text(
                          result.specializations.first.name,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      const SizedBox(height: 8),

                      // Rating and Distance Row
                      Row(
                        children: [
                          // Rating
                          if (result.averageRating != null &&
                              result.averageRating! > 0) ...[
                            Icon(
                              Icons.star_rounded,
                              size: 16,
                              color: AppColors.warningOrange,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              result.averageRating!.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            if (result.totalRatings != null &&
                                result.totalRatings! > 0) ...[
                              const SizedBox(width: 2),
                              Text(
                                '(${result.totalRatings})',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                            const SizedBox(width: 12),
                          ],

                          // Distance
                          if (result.distanceKm != null) ...[
                            Icon(
                              Icons.location_on_rounded,
                              size: 14,
                              color: AppColors.primaryBlue,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${result.distanceKm!.toStringAsFixed(1)} km',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Badges Row
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: [
                          // Available Today Badge
                          if (result.availableToday == true)
                            _buildBadge(
                              'Available Today',
                              AppColors.successGreen,
                              Icons.check_circle_rounded,
                            ),

                          // Online Badge
                          if (result.isOnline == true)
                            _buildBadge(
                              'Online',
                              AppColors.primaryGreen,
                              Icons.circle,
                            ),

                          // Consultation Type Badges
                          if (result.consultationTypes != null)
                            ...result.consultationTypes!.take(2).map((type) {
                              return _buildConsultationTypeBadge(type);
                            }),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow Icon
                const SizedBox(width: 8),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 16,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.grey200,
              width: 2,
            ),
            image: result.imageUrl != null
                ? DecorationImage(
                    image: NetworkImage(result.imageUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
            color: result.imageUrl == null ? AppColors.grey200 : null,
          ),
          child: result.imageUrl == null
              ? Icon(
                  Icons.person_rounded,
                  size: 32,
                  color: AppColors.grey500,
                )
              : null,
        ),
        // Online Status Indicator
        if (result.isOnline == true)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: AppColors.successGreen,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBadge(String label, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsultationTypeBadge(String type) {
    IconData icon;
    Color color;
    String label;

    switch (type.toLowerCase()) {
      case 'instant':
        icon = Icons.flash_on_rounded;
        color = AppColors.warningOrange;
        label = 'Instant';
        break;
      case 'online':
        icon = Icons.videocam_rounded;
        color = AppColors.primaryBlue;
        label = 'Online';
        break;
      case 'offline':
        icon = Icons.location_city_rounded;
        color = AppColors.infoBlue;
        label = 'In-Clinic';
        break;
      default:
        icon = Icons.medical_services_rounded;
        color = AppColors.grey600;
        label = type;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 12,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
