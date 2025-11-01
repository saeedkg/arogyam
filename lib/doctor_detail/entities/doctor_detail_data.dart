class DoctorDetailData {
  final String id;
  final String name;
  final String specialization;
  final String bio;
  final String consultationFee;
  final int consultationDuration;
  final double rating;
  final int totalRatings;
  final bool isVerified;
  final String imageUrl;

  DoctorDetailData({
    required this.id,
    required this.name,
    required this.specialization,
    required this.bio,
    required this.consultationFee,
    required this.consultationDuration,
    required this.rating,
    required this.totalRatings,
    required this.isVerified,
    required this.imageUrl,
  });

  factory DoctorDetailData.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final doctor = data['doctor'] as Map<String, dynamic>;
    final user = doctor['user'] as Map<String, dynamic>;
    final specs = (doctor['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specialization = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final rating = double.tryParse(doctor['average_rating']?.toString() ?? '0') ?? 0.0;
    final totalRatings = (doctor['total_ratings'] is int) ? doctor['total_ratings'] as int : int.tryParse('${doctor['total_ratings'] ?? 0}') ?? 0;

    return DoctorDetailData(
      id: '${doctor['id']}',
      name: user['name'] as String? ?? 'Doctor',
      specialization: specialization,
      bio: doctor['bio'] as String? ?? '',
      consultationFee: doctor['consultation_fee'] as String? ?? '0.00',
      consultationDuration: doctor['consultation_duration'] as int? ?? 30,
      rating: rating,
      totalRatings: totalRatings,
      isVerified: doctor['is_verified'] as bool? ?? false,
      imageUrl: 'https://i.pravatar.cc/150?img=22',
    );
  }
}

