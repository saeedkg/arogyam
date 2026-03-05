import 'trending_specialization.dart';

class PopularSearches {
  final List<String> popularSearches;
  final List<TrendingSpecialization> trendingSpecializations;
  final int instantAvailableCount;

  PopularSearches({
    required this.popularSearches,
    required this.trendingSpecializations,
    required this.instantAvailableCount,
  });

  factory PopularSearches.fromJson(Map<String, dynamic> json) {
    return PopularSearches(
      popularSearches: json['popular_searches'] != null
          ? List<String>.from(json['popular_searches'])
          : [],
      trendingSpecializations: json['trending_specializations'] != null
          ? (json['trending_specializations'] as List)
              .map((e) => TrendingSpecialization.fromJson(e))
              .toList()
          : [],
      instantAvailableCount: json['instant_available_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'popular_searches': popularSearches,
      'trending_specializations':
          trendingSpecializations.map((e) => e.toJson()).toList(),
      'instant_available_count': instantAvailableCount,
    };
  }
}
