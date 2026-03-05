import '../../common_services/entities/specialization.dart';
import 'nearest_location.dart';

class SearchResultItem {
  final String id;
  final String name;
  final String entityType;
  final List<Specialization> specializations;
  final double? averageRating;
  final int? consultationFee;
  final double? distanceKm;
  final NearestLocation? nearestLocation;
  final bool? isOnline;
  final bool? availableToday;
  final List<String>? consultationTypes;
  final String? imageUrl;
  final int? totalRatings;

  SearchResultItem({
    required this.id,
    required this.name,
    required this.entityType,
    required this.specializations,
    this.averageRating,
    this.consultationFee,
    this.distanceKm,
    this.nearestLocation,
    this.isOnline,
    this.availableToday,
    this.consultationTypes,
    this.imageUrl,
    this.totalRatings,
  });

  factory SearchResultItem.fromJson(Map<String, dynamic> json) {
    return SearchResultItem(
      id: json['id']?.toString() ?? '',
      name: json['name'] ?? '',
      entityType: json['entity_type'] ?? 'doctor',
      specializations: json['specializations'] != null
          ? (json['specializations'] as List)
              .map((e) => Specialization.fromJson(e))
              .toList()
          : [],
      averageRating: json['average_rating']?.toDouble(),
      consultationFee: json['consultation_fee'],
      distanceKm: json['distance_km']?.toDouble(),
      nearestLocation: json['nearest_location'] != null
          ? NearestLocation.fromJson(json['nearest_location'])
          : null,
      isOnline: json['is_online'],
      availableToday: json['available_today'],
      consultationTypes: json['consultation_types'] != null
          ? List<String>.from(json['consultation_types'])
          : null,
      imageUrl: json['image_url'],
      totalRatings: json['total_ratings'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'entity_type': entityType,
      'specializations': specializations.map((e) => e.toJson()).toList(),
      'average_rating': averageRating,
      'consultation_fee': consultationFee,
      'distance_km': distanceKm,
      'nearest_location': nearestLocation?.toJson(),
      'is_online': isOnline,
      'available_today': availableToday,
      'consultation_types': consultationTypes,
      'image_url': imageUrl,
      'total_ratings': totalRatings,
    };
  }
}
