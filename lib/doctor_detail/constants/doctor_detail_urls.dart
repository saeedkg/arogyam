import '../../_shared/constants/network_config.dart';

class DoctorDetailUrls {
  static String getDoctorDetailUrl(String doctorId) {
    return '${NetworkConfig.baseUrl}/doctors/$doctorId';
  }
}

