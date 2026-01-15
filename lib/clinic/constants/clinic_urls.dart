import '../../_shared/constants/network_config.dart';

class ClinicUrls {
  static String getClinicDetailUrl(String clinicId) {
    return '${NetworkConfig.baseUrl}/patient/clinics/$clinicId';
  }
}
