import '../../_shared/constants/network_config.dart';

class BookingUrls {
  static String bookAppointmentUrl() {
    return '${NetworkConfig.baseUrl}/patient/appointments';
  }

  static String videoConsultationPricingUrl() {
    return '${NetworkConfig.baseUrl}/patient/video-consultation/pricing';
  }

  static String videoConsultationCreateOrderUrl() {
    return '${NetworkConfig.baseUrl}/patient/video-consultation/create-order';
  }

  static String videoConsultationCompleteUrl() {
    return '${NetworkConfig.baseUrl}/patient/video-consultation/complete';
  }

  static String cancelPendingPaymentUrl() {
    return '${NetworkConfig.baseUrl}/patient/booking/cancel-pending-payment';
  }
}
