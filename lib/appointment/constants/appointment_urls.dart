import '../../_shared/constants/network_config.dart';

class AppointmentsUrls {
  /// Fetch list of appointments
  static String getAppointmentsUrl() {
    return '${NetworkConfig.baseUrl}/patient/appointments';
  }

  /// Fetch single appointment detail
  static String getAppointmentDetailUrl(int id) {
    return '${NetworkConfig.baseUrl}/patient/appointments/$id';
  }
}
