import 'package:flutter/material.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../entities/fuzzy_suggestions.dart';
import '../../entities/search_suggestion.dart';

class FuzzySuggestionsWidget extends StatelessWidget {
  final FuzzySuggestions suggestions;
  final Function(SearchSuggestion) onSuggestionTapped;

  const FuzzySuggestionsWidget({
    super.key,
    required this.suggestions,
    required this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Main message container
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Icon
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.warningOrange.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.search_off_rounded,
                    size: 32,
                    color: AppColors.warningOrange,
                  ),
                ),
                const SizedBox(height: 16),

                // Message
                Text(
                  suggestions.message,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey700,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // "Did you mean?" section
          if (suggestions.didYouMean.isNotEmpty) ...[
            _buildSectionHeader('Did you mean?', Icons.lightbulb_outline_rounded),
            const SizedBox(height: 12),
            ...suggestions.didYouMean.map((suggestion) {
              return _buildDidYouMeanCard(suggestion);
            }),
            const SizedBox(height: 24),
          ],

          // Related searches section
          if (suggestions.relatedSearches.isNotEmpty) ...[
            _buildSectionHeader('Related Searches', Icons.explore_outlined),
            const SizedBox(height: 12),
            _buildRelatedSearchesChips(suggestions.relatedSearches),
          ],
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColors.primaryGreen,
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildDidYouMeanCard(SearchSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withValues(alpha: 0.3),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onSuggestionTapped(suggestion),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryGreen.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.auto_fix_high_rounded,
                    size: 24,
                    color: AppColors.primaryGreen,
                  ),
                ),
                const SizedBox(width: 16),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              suggestion.text,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (suggestion.similarity != null) ...[
                            const SizedBox(width: 8),
                            _buildSimilarityBadge(suggestion.similarity!),
                          ],
                        ],
                      ),
                      if (suggestion.subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          suggestion.subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Arrow
                Icon(
                  Icons.arrow_forward_rounded,
                  size: 20,
                  color: AppColors.primaryGreen,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSimilarityBadge(double similarity) {
    final percentage = (similarity * 100).round();
    final color = _getSimilarityColor(similarity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '$percentage%',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }

  Color _getSimilarityColor(double similarity) {
    if (similarity >= 0.8) {
      return AppColors.successGreen;
    } else if (similarity >= 0.6) {
      return AppColors.primaryGreen;
    } else {
      return AppColors.warningOrange;
    }
  }

  Widget _buildRelatedSearchesChips(List<SearchSuggestion> relatedSearches) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: relatedSearches.map((suggestion) {
        return _buildRelatedSearchChip(suggestion);
      }).toList(),
    );
  }

  Widget _buildRelatedSearchChip(SearchSuggestion suggestion) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onSuggestionTapped(suggestion),
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
                suggestion.text,
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
}
