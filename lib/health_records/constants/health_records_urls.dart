import '../../_shared/constants/network_config.dart';

class HealthRecordsUrls {
  static String getHealthRecordsUrl({String? patientId}) {
    final baseUrl = '${NetworkConfig.baseUrl}/patient/health-records';
    
    // Don't append patientId if it's null or "self"
    if (patientId == null || patientId.toLowerCase() == 'self') {
      return baseUrl;
    }
    
    return '$baseUrl/patient_id=$patientId';
  }

  static String getHealthRecordsForAppointmentUrl(String appointmentId) {
    return '${NetworkConfig.baseUrl}/patient/health-records?appointment_id=$appointmentId';
  }

  static String getHealthRecordDownloadUrl(String healthRecordId) {
    return '${NetworkConfig.baseUrl}/patient/health-records/$healthRecordId/download';
  }
}

