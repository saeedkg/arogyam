import '../../_shared/constants/network_config.dart';

class InstantConsultUrls {
  static String getInstantAvailableDoctorsUrl() {
    return '${NetworkConfig.baseUrl}/patient/doctors/instant-available';
  }

  static String getPricingUrl() {
    return '${NetworkConfig.baseUrl}/patient/instant-consultation/pricing';
  }

  static String getCreateOrderUrl() {
    return '${NetworkConfig.baseUrl}/patient/instant-consultation/create-order';
  }

  static String getCompletePaymentUrl() {
    return '${NetworkConfig.baseUrl}/patient/instant-consultation/complete';
  }
}

