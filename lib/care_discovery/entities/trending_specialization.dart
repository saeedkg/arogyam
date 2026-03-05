class TrendingSpecialization {
  final int id;
  final String name;
  final String? svgIcon;
  final int doctorCount;

  TrendingSpecialization({
    required this.id,
    required this.name,
    this.svgIcon,
    required this.doctorCount,
  });

  factory TrendingSpecialization.fromJson(Map<String, dynamic> json) {
    return TrendingSpecialization(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      svgIcon: json['svg_icon'],
      doctorCount: json['doctor_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'svg_icon': svgIcon,
      'doctor_count': doctorCount,
    };
  }
}
