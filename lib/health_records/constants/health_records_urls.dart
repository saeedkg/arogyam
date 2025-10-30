import '../../_shared/constants/network_config.dart';

class HealthRecordsUrls {
  static String getHealthRecordsUrl() {
    return '${NetworkConfig.baseUrl}/patient/health-records';
  }
}

