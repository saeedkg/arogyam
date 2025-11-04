import '../../_shared/constants/network_config.dart';

class DoctorUrls {
  static String getDoctorsListUrl() {
    // Update this path if your backend differs
    //return '${NetworkConfig.baseUrl}/patient/doctors/instant-available';
    return '${NetworkConfig.baseUrl}/patient/doctors/featured';
  }

  static String getDoctorDetailUrl(String id) {
    return '${NetworkConfig.baseUrl}/patient/doctors/$id';
  }

  static String getDoctorSlotsUrl(String id, String date) {
    return '${NetworkConfig.baseUrl}/patient/doctors/$id/slots?date=$date';
  }
}


