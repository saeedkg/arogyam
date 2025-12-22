import '../../_shared/constants/network_config.dart';

class AppointmentsUrls {
  /// Fetch list of appointments with pagination
  static String getAppointmentsUrl({
    int page = 1,
    int perPage = 10,
    String? patientId,
  }) {
    String url = '${NetworkConfig.baseUrl}/patient/appointments?page=$page&per_page=$perPage';
    
    // Add patient_id if provided
    final intId = int.tryParse(patientId ?? '');
    if (intId != null) {
      url += '&family_member_id=$intId';
    }

    // if (patientId != null && patientId.isNotEmpty) {
    //   url += '&family_member_id=$patientId';
    // }
    
    return url;
  }

  /// Fetch single appointment detail
  static String getAppointmentDetailUrl(int id) {
    return '${NetworkConfig.baseUrl}/patient/appointments/$id';
  }
}
