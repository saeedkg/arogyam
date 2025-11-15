import '../../_shared/constants/network_config.dart';

class CommonUrls {
  /// Fetch list of specializations
  static String getSpecializationsUrl() {
    return '${NetworkConfig.baseUrl}/doctors/specializations';
  }

  /// Fetch list of doctors
  static String getDoctorsUrl({int page = 1, int perPage = 10, String? search}) {
    String url = '${NetworkConfig.baseUrl}/doctors/featured?page=$page&per_page=$perPage';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    return url;
  }
  
  static String getDoctorsBySpecializationUrl(String specialization, {int page = 1, int perPage = 10, String? search}) {
    String url = '${NetworkConfig.baseUrl}/doctors/specialization/$specialization?page=$page&per_page=$perPage';
    if (search != null && search.isNotEmpty) {
      url += '&search=$search';
    }
    return url;
  }
}
