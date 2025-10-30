class HealthRecord {
  final String id;
  final String title;
  final String category;
  final String? notes;
  final DateTime date;
  final String? fileUrl;

  const HealthRecord({
    required this.id,
    required this.title,
    required this.category,
    this.notes,
    required this.date,
    this.fileUrl,
  });
}
