class BookingDetail {
  final String id;
  final String doctorName;
  final String specialization;
  final String hospital;
  final String imageUrl;
  final DateTime startTime;
  final DateTime endTime;
  final String status; // Confirmed, Pending, Completed

  // prescription
  final bool prescriptionAvailable;
  final String? prescriptionUrl;

  // payment
  final double amountPaid;
  final String paymentStatus;
  final String transactionId;

  const BookingDetail({
    required this.id,
    required this.doctorName,
    required this.specialization,
    required this.hospital,
    required this.imageUrl,
    required this.startTime,
    required this.endTime,
    required this.status,
    required this.prescriptionAvailable,
    this.prescriptionUrl,
    required this.amountPaid,
    required this.paymentStatus,
    required this.transactionId,
  });
}

