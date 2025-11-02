import '../../_shared/constants/network_config.dart';

class CommonUrls {
  /// Fetch list of specializations
  static String getSpecializationsUrl() {
    return '${NetworkConfig.baseUrl}/doctors/specializations';
  }

  /// Fetch list of doctors
  static String getDoctorsUrl() {
    return '${NetworkConfig.baseUrl}/doctors/featured';
  }
  static String getDoctorsBySpecializationUrl(String specialization) {
    return '${NetworkConfig.baseUrl}/doctors/specialization/$specialization';
  }
}
