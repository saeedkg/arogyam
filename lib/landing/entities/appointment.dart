class Appointment {
  final String id;
  final String doctorName;
  final String specialization;
  final DateTime startTime;
  final bool isVideo;

  const Appointment({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.startTime,
    this.isVideo = true,
  });
}

