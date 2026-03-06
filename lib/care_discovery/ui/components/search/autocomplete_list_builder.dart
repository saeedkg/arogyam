import 'package:flutter/material.dart';
import '../../../../_shared/ui/app_colors.dart';
import '../../../entities/search/search_suggestion.dart';

class AutocompleteListBuilder extends StatelessWidget {
  final Map<String, List<SearchSuggestion>> groupedSuggestions;
  final Function(SearchSuggestion) onSuggestionTapped;

  const AutocompleteListBuilder({
    super.key,
    required this.groupedSuggestions,
    required this.onSuggestionTapped,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      itemCount: _getTotalItemCount(),
      itemBuilder: (context, index) {
        return _buildItem(context, index);
      },
    );
  }

  int _getTotalItemCount() {
    int count = 0;
    for (final entry in groupedSuggestions.entries) {
      count += 1; // Header
      count += entry.value.length; // Items
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index) {
    int currentIndex = 0;

    for (final entry in groupedSuggestions.entries) {
      // Check if this is a header
      if (currentIndex == index) {
        return _buildCategoryHeader(entry.key);
      }
      currentIndex++;

      // Check if this is one of the items
      for (final suggestion in entry.value) {
        if (currentIndex == index) {
          return _buildSuggestionCard(suggestion);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategoryHeader(String category) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w700,
          color: AppColors.grey600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSuggestionCard(SearchSuggestion suggestion) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.grey200,
          width: 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onSuggestionTapped(suggestion),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                // Icon
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: _getIconBackgroundColor(suggestion.type),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getIconForType(suggestion.type),
                    size: 20,
                    color: _getIconColor(suggestion.type),
                  ),
                ),
                const SizedBox(width: 12),

                // Text content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        suggestion.text,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (suggestion.subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          suggestion.subtitle!,
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.grey600,
                            fontWeight: FontWeight.w400,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // Arrow icon
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: AppColors.grey400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'specialization':
        return Icons.local_hospital_rounded;
      case 'symptom':
        return Icons.healing_rounded;
      case 'doctor':
        return Icons.person_rounded;
      default:
        return Icons.search_rounded;
    }
  }

  Color _getIconBackgroundColor(String type) {
    switch (type) {
      case 'specialization':
        return AppColors.primaryGreen.withValues(alpha: 0.1);
      case 'symptom':
        return AppColors.warningOrange.withValues(alpha: 0.1);
      case 'doctor':
        return AppColors.primaryBlue.withValues(alpha: 0.1);
      default:
        return AppColors.grey200;
    }
  }

  Color _getIconColor(String type) {
    switch (type) {
      case 'specialization':
        return AppColors.primaryGreen;
      case 'symptom':
        return AppColors.warningOrange;
      case 'doctor':
        return AppColors.primaryBlue;
      default:
        return AppColors.grey600;
    }
  }
}
