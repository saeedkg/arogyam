class MedicalCenter {
  final String id;
  final String name;
  final String imageUrl;
  final String address;
  final double rating;
  final double distance;

  const MedicalCenter({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.address,
    this.rating = 4.8,
    this.distance = 2.5,
  });
}
