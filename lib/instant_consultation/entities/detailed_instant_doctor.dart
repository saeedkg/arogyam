class DetailedInstantDoctor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final double rating;
  final int totalRatings;
  final int totalConsultations;
  final int yearsOfExperience;
  final List<String> qualifications;
  final String consultationFee;
  final bool isVerified;
  final bool availableToday;

  DetailedInstantDoctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    required this.rating,
    required this.totalRatings,
    required this.totalConsultations,
    required this.yearsOfExperience,
    required this.qualifications,
    required this.consultationFee,
    required this.isVerified,
    required this.availableToday,
  });

  factory DetailedInstantDoctor.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>?;
    final specs = (json['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final pivot = firstSpec?['pivot'] as Map<String, dynamic>?;
    final specializationName = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final rating = double.tryParse(json['average_rating']?.toString() ?? '0') ?? 0.0;
    final totalRatings = (json['total_ratings'] is int) ? json['total_ratings'] as int : int.tryParse('${json['total_ratings'] ?? 0}') ?? 0;
    final totalConsultations = json['total_consultations'] is int ? json['total_consultations'] as int : int.tryParse('${json['total_consultations'] ?? 0}') ?? 0;
    final yearsExp = pivot?['years_of_experience'] is int ? pivot!['years_of_experience'] as int : int.tryParse('${pivot?['years_of_experience'] ?? 0}') ?? 0;
    final quals = (json['qualifications'] as List<dynamic>? ?? const []).map((e) => e.toString()).toList();

    return DetailedInstantDoctor(
      id: '${json['id']}',
      name: user?['name'] as String? ?? 'Doctor',
      specialization: specializationName,
      imageUrl: 'https://i.pravatar.cc/150?img=10',
      rating: rating,
      totalRatings: totalRatings,
      totalConsultations: totalConsultations,
      yearsOfExperience: yearsExp,
      qualifications: quals,
      consultationFee: json['consultation_fee'] as String? ?? '0.00',
      isVerified: json['is_verified'] as bool? ?? false,
      availableToday: json['available_today'] as bool? ?? false,
    );
  }
}

