class Specialization {
  final int id;
  final String name;
  final String? icon;

  Specialization({
    required this.id,
    required this.name,
    this.icon,
  });

  factory Specialization.fromJson(Map<String, dynamic> json) {
    return Specialization(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}
