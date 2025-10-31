import '../../_shared/constants/network_config.dart';

class ConsultationUrls {
  static String getPendingConsultationUrl(String appointmentId) {
    return '${NetworkConfig.baseUrl}/patient/appointments/$appointmentId';
  }

  static String joinConsultationUrl(String consultationId) {
    return '${NetworkConfig.baseUrl}/video-consultation/consultations/$consultationId/join';
  }
}

