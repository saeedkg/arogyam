import 'package:flutter/material.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../entities/popular_searches.dart';
import '../../entities/trending_specialization.dart';

class PopularSearchesWidget extends StatelessWidget {
  final PopularSearches popularSearches;
  final Function(String) onPopularSearchTapped;
  final Function(TrendingSpecialization) onTrendingSpecializationTapped;

  const PopularSearchesWidget({
    super.key,
    required this.popularSearches,
    required this.onPopularSearchTapped,
    required this.onTrendingSpecializationTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Instant Available Badge
          if (popularSearches.instantAvailableCount > 0) ...[
            _buildInstantAvailableBadge(),
            const SizedBox(height: 24),
          ],

          // Popular Searches Section
          if (popularSearches.popularSearches.isNotEmpty) ...[
            _buildSectionHeader('Popular Searches', Icons.trending_up_rounded),
            const SizedBox(height: 12),
            _buildPopularSearchChips(),
            const SizedBox(height: 32),
          ],

          // Trending Specializations Section
          if (popularSearches.trendingSpecializations.isNotEmpty) ...[
            _buildSectionHeader(
                'Trending Specializations', Icons.local_fire_department_rounded),
            const SizedBox(height: 16),
            _buildTrendingSpecializations(),
          ],
        ],
      ),
    );
  }

  Widget _buildInstantAvailableBadge() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.flash_on_rounded,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Instant Consultation',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${popularSearches.instantAvailableCount} doctors available now',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.8),
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: AppColors.primaryGreen,
          ),
        ),
        const SizedBox(width: 12),
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSearchChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: popularSearches.popularSearches.map((search) {
        return _buildSearchChip(search);
      }).toList(),
    );
  }

  Widget _buildSearchChip(String searchTerm) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onPopularSearchTapped(searchTerm),
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.grey300,
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.search_rounded,
                size: 16,
                color: AppColors.grey600,
              ),
              const SizedBox(width: 6),
              Text(
                searchTerm,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTrendingSpecializations() {
    return Column(
      children: popularSearches.trendingSpecializations.map((spec) {
        return _buildTrendingSpecializationCard(spec);
      }).toList(),
    );
  }

  Widget _buildTrendingSpecializationCard(TrendingSpecialization spec) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          onTap: () => onTrendingSpecializationTapped(spec),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon Container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColors.primaryGreen,
                        AppColors.primaryGreen.withValues(alpha: 0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(
                    Icons.local_hospital_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        spec.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.person_outline_rounded,
                            size: 14,
                            color: AppColors.grey600,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${spec.doctorCount} doctors',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.warningOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.trending_up_rounded,
                                  size: 12,
                                  color: AppColors.warningOrange,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Trending',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warningOrange,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Arrow
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
}
