class InstantDoctor {
  final String id;
  final String name;
  final String specialization;
  final String imageUrl;
  final double rating;

  const InstantDoctor({
    required this.id,
    required this.name,
    required this.specialization,
    required this.imageUrl,
    this.rating = 4.8,
  });
}

