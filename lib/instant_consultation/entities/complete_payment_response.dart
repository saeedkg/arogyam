class CompletePaymentResponse {
  final String appointmentId;

  const CompletePaymentResponse({
    required this.appointmentId,
  });

  factory CompletePaymentResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    final appointment = data['appointment'] as Map<String, dynamic>;
    
    return CompletePaymentResponse(
      appointmentId: '${appointment['id']}',
    );
  }
}
