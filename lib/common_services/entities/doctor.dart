class Doctor {
  final int id;
  final String name;
  final List<String> qualifications;
  final double consultationFee;
  final int totalConsultations;
  final double averageRating;
  final int totalRatings;

  Doctor({
    required this.id,
    required this.name,
    required this.qualifications,
    required this.consultationFee,
    required this.totalConsultations,
    required this.averageRating,
    required this.totalRatings,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    final user = json['user'] ?? {};
    return Doctor(
      id: json['id'] ?? 0,
      name: user['name'] ?? '',
      qualifications: (json['qualifications'] is List)
          ? List<String>.from(json['qualifications'])
          : [],
      consultationFee: double.tryParse(json['consultation_fee']?.toString() ?? '0') ?? 0.0,
      totalConsultations: json['total_consultations'] ?? 0,
      averageRating: double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0,
      totalRatings: json['total_ratings'] ?? 0,
    );
  }
}
