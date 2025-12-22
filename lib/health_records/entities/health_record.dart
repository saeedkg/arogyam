class HealthRecord {
  final String id;
  final String title;
  final String category;
  final String? notes;
  final DateTime date;
  final String? fileUrl;
  final String? fileName;
  final String? fileType;
  final int? fileSize;
  final String type;

  const HealthRecord({
    required this.id,
    required this.title,
    required this.category,
    this.notes,
    required this.date,
    this.fileUrl,
    this.fileName,
    this.fileType,
    this.fileSize,
    required this.type,
  });

  bool get isImage => fileType?.startsWith('image/') == true;
  bool get isPdf => fileType == 'application/pdf';
  
  String get displayFileSize {
    if (fileSize == null) return '';
    final kb = fileSize! / 1024;
    if (kb < 1024) {
      return '${kb.toStringAsFixed(1)} KB';
    }
    final mb = kb / 1024;
    return '${mb.toStringAsFixed(1)} MB';
  }
}
