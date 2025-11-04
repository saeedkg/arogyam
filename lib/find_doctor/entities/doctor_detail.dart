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
  });
}

