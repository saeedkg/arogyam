class Specialization {
  final int id;
  final String name;
  final String? svgIcon;

  Specialization({
    required this.id,
    required this.name,
    this.svgIcon,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      svgIcon: json['svg_icon'],
    );
  }
}
