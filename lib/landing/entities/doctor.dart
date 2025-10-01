class Doctor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final double rating;

  const Doctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    this.rating = 4.8,
  });
}

