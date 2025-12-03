class Pricing {
  final double consultationFee;
  final double platformFee;
  final double platformFeePercentage;
  final double totalAmount;

  const Pricing({
    required this.consultationFee,
    required this.platformFee,
    required this.platformFeePercentage,
    required this.totalAmount,
  });

  factory Pricing.fromJson(Map<String, dynamic> json) {
    final data = json['data'] as Map<String, dynamic>;
    return Pricing(
      consultationFee: double.tryParse(data['consultation_fee']?.toString() ?? '0') ?? 0.0,
      platformFee: double.tryParse(data['platform_fee']?.toString() ?? '0') ?? 0.0,
      platformFeePercentage: double.tryParse(data['platform_fee_percentage']?.toString() ?? '0') ?? 0.0,
      totalAmount: double.tryParse(data['total_amount']?.toString() ?? '0') ?? 0.0,
    );
  }
}
