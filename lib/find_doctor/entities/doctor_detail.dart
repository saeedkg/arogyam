class DoctorDetail {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final String bio;
  final int experienceYears;
  final int fee;
  final List<DateTime> availableDates; // first 4 days
  
  // New fields from API
  final List<String>? qualifications;
  final List<String>? languages;
  final List<Map<String, dynamic>>? specializations;
  final String? availabilityStatus;
  final bool? availableToday;
  final int? todaySlotsCount;
  final int? totalConsultations;
  final bool? isVerified;
  final String? consultationFee;

  const DoctorDetail({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    required this.bio,
    required this.experienceYears,
    required this.fee,
    required this.availableDates,
    this.qualifications,
    this.languages,
    this.specializations,
    this.availabilityStatus,
    this.availableToday,
    this.todaySlotsCount,
    this.totalConsultations,
    this.isVerified,
    this.consultationFee,
  });
}

