class PaymentMethod {
  final String id;
  final String name;
  final String icon;
  final bool isAvailable;

  const PaymentMethod({
    required this.id,
    required this.name,
    required this.icon,
    this.isAvailable = true,
  });
}

class PaymentDetails {
  final String id;
  final double consultationFee;
  final double platformFee;
  final double gst;
  final double totalAmount;
  final String currency;

  const PaymentDetails({
    required this.id,
    required this.consultationFee,
    required this.platformFee,
    required this.gst,
    required this.totalAmount,
    required this.currency,
  });

  factory PaymentDetails.fromJson(Map<String, dynamic> json) {
    return PaymentDetails(
      id: json['id']?.toString() ?? '',
      consultationFee: (json['consultation_fee'] as num?)?.toDouble() ?? 0.0,
      platformFee: (json['platform_fee'] as num?)?.toDouble() ?? 0.0,
      gst: (json['gst'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['total_amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] as String? ?? 'INR',
    );
  }
}

class PaymentResponse {
  final String transactionId;
  final String status;
  final String message;
  final DateTime timestamp;

  const PaymentResponse({
    required this.transactionId,
    required this.status,
    required this.message,
    required this.timestamp,
  });

  factory PaymentResponse.fromJson(Map<String, dynamic> json) {
    return PaymentResponse(
      transactionId: json['transaction_id'] as String? ?? '',
      status: json['status'] as String? ?? 'pending',
      message: json['message'] as String? ?? '',
      timestamp: json['timestamp'] != null
          ? DateTime.parse(json['timestamp'] as String)
          : DateTime.now(),
    );
  }
}

