class DoctorListItem {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final bool favorite;
  final bool isOnline;
  final int experience;
  final String education;
  final String consultationFee;
  final bool availableToday;


  const DoctorListItem({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    this.favorite = false,
    this.isOnline=true,
    this.experience=5,
    required this.education,
    required this.consultationFee,
    this.availableToday=true

  });
}

