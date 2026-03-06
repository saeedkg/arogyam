import 'search_suggestion.dart';

class FuzzySuggestions {
  final List<SearchSuggestion> didYouMean;
  final List<SearchSuggestion> relatedSearches;
  final String message;

  FuzzySuggestions({
    required this.didYouMean,
    required this.relatedSearches,
    required this.message,
  });

  factory FuzzySuggestions.fromJson(Map<String, dynamic> json) {
    // Parse did_you_mean - can be either an object with numbered keys or an array
    List<SearchSuggestion> didYouMeanList = [];
    if (json['did_you_mean'] != null) {
      final didYouMeanData = json['did_you_mean'];
      
      if (didYouMeanData is List) {
        // If it's already a list
        didYouMeanList = didYouMeanData
            .map((e) => SearchSuggestion.fromJson(e))
            .toList();
      } else if (didYouMeanData is Map) {
        // If it's an object with numbered keys, convert to list
        didYouMeanList = didYouMeanData.values
            .map((e) => SearchSuggestion.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }
    
    return FuzzySuggestions(
      didYouMean: didYouMeanList,
      relatedSearches: json['related_searches'] != null
          ? (json['related_searches'] as List)
              .map((e) => SearchSuggestion.fromJson(e))
              .toList()
          : [],
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'did_you_mean': didYouMean.map((e) => e.toJson()).toList(),
      'related_searches': relatedSearches.map((e) => e.toJson()).toList(),
      'message': message,
    };
  }

  bool get hasSuggestions =>
      didYouMean.isNotEmpty || relatedSearches.isNotEmpty;
}
