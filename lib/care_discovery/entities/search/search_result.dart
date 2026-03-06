import 'search_result_item.dart';
import 'search_pagination.dart';
import 'fuzzy_suggestions.dart';

class SearchResult {
  final List<SearchResultItem> results;
  final SearchPagination pagination;
  final SearchMetadata? metadata;
  final FuzzySuggestions? suggestions;

  SearchResult({
    required this.results,
    required this.pagination,
    this.metadata,
    this.suggestions,
  });

  factory SearchResult.fromJson(Map<String, dynamic> json) {
    // Build FuzzySuggestions from root-level fields if they exist
    FuzzySuggestions? suggestions;
    
    // Check if did_you_mean or related_searches exist at root level
    final hasDidYouMean = json['did_you_mean'] != null && 
                          (json['did_you_mean'] is List ? (json['did_you_mean'] as List).isNotEmpty : true);
    final hasRelatedSearches = json['related_searches'] != null && 
                               (json['related_searches'] is List ? (json['related_searches'] as List).isNotEmpty : true);
    
    if (hasDidYouMean || hasRelatedSearches) {
      suggestions = FuzzySuggestions.fromJson({
        'did_you_mean': json['did_you_mean'],
        'related_searches': json['related_searches'],
        'message': json['message'] ?? 'No results found',
      });
    } else if (json['suggestions'] != null && json['suggestions'] is Map) {
      // Only parse nested suggestions if it's a Map (not an empty array)
      suggestions = FuzzySuggestions.fromJson(json['suggestions']);
    }
    
    return SearchResult(
      results: json['results'] != null
          ? (json['results'] as List)
              .map((e) => SearchResultItem.fromJson(e))
              .toList()
          : [],
      pagination: json['pagination'] != null
          ? SearchPagination.fromJson(json['pagination'])
          : SearchPagination(
              currentPage: 1,
              perPage: 20,
              total: 0,
              lastPage: 1,
            ),
      metadata: json['search_metadata'] != null
          ? SearchMetadata.fromJson(json['search_metadata'])
          : null,
      suggestions: suggestions,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'results': results.map((e) => e.toJson()).toList(),
      'pagination': pagination.toJson(),
      'search_metadata': metadata?.toJson(),
      'suggestions': suggestions?.toJson(),
    };
  }

  bool get hasResults => results.isNotEmpty;
  bool get hasSuggestions => suggestions?.hasSuggestions ?? false;
}

class SearchMetadata {
  final int responseTimeMs;
  final String query;
  final bool hasResults;

  SearchMetadata({
    required this.responseTimeMs,
    required this.query,
    required this.hasResults,
  });

  factory SearchMetadata.fromJson(Map<String, dynamic> json) {
    return SearchMetadata(
      responseTimeMs: json['response_time_ms'] ?? 0,
      query: json['query'] ?? '',
      hasResults: json['has_results'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'response_time_ms': responseTimeMs,
      'query': query,
      'has_results': hasResults,
    };
  }
}
