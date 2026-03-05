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
    return FuzzySuggestions(
      didYouMean: json['did_you_mean'] != null
          ? (json['did_you_mean'] as List)
              .map((e) => SearchSuggestion.fromJson(e))
              .toList()
          : [],
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
