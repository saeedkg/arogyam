class NearestLocation {
  final String type;
  final String name;
  final double latitude;
  final double longitude;

  NearestLocation({
    required this.type,
    required this.name,
    required this.latitude,
    required this.longitude,
  });

  factory NearestLocation.fromJson(Map<String, dynamic> json) {
    return NearestLocation(
      type: json['type'] ?? '',
      name: json['name'] ?? '',
      latitude: (json['latitude'] ?? 0).toDouble(),
      longitude: (json['longitude'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'name': name,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
