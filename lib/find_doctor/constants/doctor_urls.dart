import '../../_shared/constants/network_config.dart';

class DoctorUrls {
  static String getDoctorsListUrl() {
    // Update this path if your backend differs
    return '${NetworkConfig.baseUrl}/patient/doctors/instant-available';
  }

  static String getDoctorDetailUrl(String id) {
    return '${NetworkConfig.baseUrl}/patient/doctors/$id';
  }
}


