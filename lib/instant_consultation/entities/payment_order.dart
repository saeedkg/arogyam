import 'pricing.dart';

class PaymentOrder {
  final String orderId;
  final double amount;
  final String currency;
  final String razorpayKey;
  final Pricing pricing;

  const PaymentOrder({
    required this.orderId,
    required this.amount,
    required this.currency,
    required this.razorpayKey,
    required this.pricing,
  });

  factory PaymentOrder.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return PaymentOrder(
      orderId: data['order_id'] as String,
      amount: double.tryParse(data['amount']?.toString() ?? '0') ?? 0.0,
      currency: data['currency'] as String? ?? 'INR',
      razorpayKey: data['razorpay_key'] as String,
      pricing: Pricing.fromJson({'data': data['pricing']}),
    );
  }
}
