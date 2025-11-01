import '../../_shared/constants/network_config.dart';

class CommonUrls {
  /// Fetch list of specializations
  static String getSpecializationsUrl() {
    return '${NetworkConfig.baseUrl}/specializations';
  }

  /// Fetch list of doctors
  static String getDoctorsUrl() {
    return '${NetworkConfig.baseUrl}/doctors/featured';
  }
}
