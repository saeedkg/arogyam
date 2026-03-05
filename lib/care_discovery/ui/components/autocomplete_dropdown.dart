import 'package:flutter/material.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../entities/search_suggestion.dart';

class AutocompleteDropdown extends StatelessWidget {
  final List<SearchSuggestion> suggestions;
  final Function(SearchSuggestion) onSuggestionTapped;
  final bool isLoading;

  const AutocompleteDropdown({
    super.key,
    required this.suggestions,
    required this.onSuggestionTapped,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return _buildLoadingState();
    }

    if (suggestions.isEmpty) {
      return const SizedBox.shrink();
    }

    // Group suggestions by category
    final groupedSuggestions = _groupByCategory(suggestions);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Material(
          color: Colors.transparent,
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            itemCount: _getTotalItemCount(groupedSuggestions),
            itemBuilder: (context, index) {
              return _buildItem(context, index, groupedSuggestions);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Loading suggestions...',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, List<SearchSuggestion>> _groupByCategory(
      List<SearchSuggestion> suggestions) {
    final Map<String, List<SearchSuggestion>> grouped = {};

    for (final suggestion in suggestions) {
      if (!grouped.containsKey(suggestion.category)) {
        grouped[suggestion.category] = [];
      }
      grouped[suggestion.category]!.add(suggestion);
    }

    return grouped;
  }

  int _getTotalItemCount(Map<String, List<SearchSuggestion>> grouped) {
    int count = 0;
    for (final entry in grouped.entries) {
      count += 1; // Header
      count += entry.value.length; // Items
    }
    return count;
  }

  Widget _buildItem(BuildContext context, int index,
      Map<String, List<SearchSuggestion>> grouped) {
    int currentIndex = 0;

    for (final entry in grouped.entries) {
      // Check if this is a header
      if (currentIndex == index) {
        return _buildCategoryHeader(entry.key);
      }
      currentIndex++;

      // Check if this is one of the items
      for (final suggestion in entry.value) {
        if (currentIndex == index) {
          return _buildSuggestionItem(context, suggestion);
        }
        currentIndex++;
      }
    }

    return const SizedBox.shrink();
  }

  Widget _buildCategoryHeader(String category) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Text(
        category,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.grey600,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSuggestionItem(BuildContext context, SearchSuggestion suggestion) {
    return InkWell(
      onTap: () => onSuggestionTapped(suggestion),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
