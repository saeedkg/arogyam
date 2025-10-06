class DoctorListItem {
  final String id;
  final String name;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final double rating;
  final int reviews;
  final bool favorite;

  const DoctorListItem({
    required this.id,
    required this.name,
    required this.specialization,
    required this.hospital,
    required this.imageUrl,
    required this.rating,
    required this.reviews,
    this.favorite = false,
  });
}

