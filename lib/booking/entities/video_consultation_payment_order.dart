import 'video_consultation_pricing.dart';

class VideoConsultationPaymentOrder {
  final String orderId;
  final double amount;
  final int amountInPaise;
  final String currency;
  final String razorpayKey;
  final VideoConsultationPricing pricing;
  final String? appointmentId; // Pending appointment ID for cancellation

  VideoConsultationPaymentOrder({
    required this.orderId,
    required this.amount,
    required this.amountInPaise,
    required this.currency,
    required this.razorpayKey,
    required this.pricing,
    this.appointmentId,
  });

  factory VideoConsultationPaymentOrder.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return VideoConsultationPaymentOrder(
      orderId: data['order_id'] as String,
      amount: double.parse(data['amount'].toString()),
      amountInPaise: data['amount_in_paise'] as int,
      currency: data['currency'] as String,
      razorpayKey: data['razorpay_key'] as String,
      pricing: VideoConsultationPricing.fromJson(data['pricing'] as Map<String, dynamic>),
      appointmentId: data['appointment_id']?.toString(),
    );
  }
}
