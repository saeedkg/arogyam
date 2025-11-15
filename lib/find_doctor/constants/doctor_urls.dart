import '../../_shared/constants/network_config.dart';

class DoctorUrls {
  static String getDoctorsListUrl({int page = 1, int perPage = 10, String? search}) {
    // Update this path if your backend differs
    //return '${NetworkConfig.baseUrl}/patient/doctors/instant-available';
    String url = '${NetworkConfig.baseUrl}/patient/doctors/featured?page=$page&per_page=$perPage';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    return url;
  }

  static String getDoctorDetailUrl(String id) {
    return '${NetworkConfig.baseUrl}/patient/doctors/$id';
  }

  static String getDoctorSlotsUrl(String id, String date) {
    return '${NetworkConfig.baseUrl}/patient/doctors/$id/slots?date=$date';
  }
}


