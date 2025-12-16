import '../../_shared/constants/network_config.dart';

class HealthRecordsUrls {
  static String getHealthRecordsUrl({String? patientId}) {
    return '${NetworkConfig.baseUrl}/patient/health-records';
  }

  static String getHealthRecordDownloadUrl(String healthRecordId) {
    return '${NetworkConfig.baseUrl}/patient/health-records/$healthRecordId/download';
  }
}

