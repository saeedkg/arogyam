class VideoConsultationPricing {
  final double consultationFee;
  final double platformFee;
  final double platformFeePercentage;
  final double totalAmount;

  VideoConsultationPricing({
    required this.consultationFee,
    required this.platformFee,
    required this.platformFeePercentage,
    required this.totalAmount,
  });

  factory VideoConsultationPricing.fromJson(Map<String, dynamic> json) {
    return VideoConsultationPricing(
      consultationFee: double.parse(json['consultation_fee'].toString()),
      platformFee: double.parse(json['platform_fee'].toString()),
      platformFeePercentage: double.parse(json['platform_fee_percentage'].toString()),
      totalAmount: double.parse(json['total_amount'].toString()),
    );
  }
}
