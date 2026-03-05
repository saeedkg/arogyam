class SearchSuggestion {
  final String type;
  final String text;
  final String? subtitle;
  final String category;
  final String icon;
  final int? id;
  final String? slug;
  final List<String>? relatedSpecializations;
  final double? similarity;
  final int? symptomId;

  SearchSuggestion({
    required this.type,
    required this.text,
    this.subtitle,
    required this.category,
    required this.icon,
    this.id,
    this.slug,
    this.relatedSpecializations,
    this.similarity,
    this.symptomId,
  });

  factory SearchSuggestion.fromJson(Map<String, dynamic> json) {
    return SearchSuggestion(
      type: json['type'] ?? '',
      text: json['text'] ?? '',
      subtitle: json['subtitle'],
      category: json['category'] ?? '',
      icon: json['icon'] ?? '',
      id: json['id'],
      slug: json['slug'],
      relatedSpecializations: json['related_specializations'] != null
          ? List<String>.from(json['related_specializations'])
          : null,
      similarity: json['similarity']?.toDouble(),
      symptomId: json['symptom_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'text': text,
      'subtitle': subtitle,
      'category': category,
      'icon': icon,
      'id': id,
      'slug': slug,
      'related_specializations': relatedSpecializations,
      'similarity': similarity,
      'symptom_id': symptomId,
    };
  }
}
