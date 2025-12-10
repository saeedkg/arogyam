class VideoConsultationCompletePaymentResponse {
  final String appointmentId;
  final String message;

  VideoConsultationCompletePaymentResponse({
    required this.appointmentId,
    required this.message,
  });

  factory VideoConsultationCompletePaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final appointment = data['appointment'] as Map<String, dynamic>;
    return VideoConsultationCompletePaymentResponse(
      appointmentId: appointment['id'].toString(),
      message: json['message'] as String,
    );
  }
}
