import '../../_shared/constants/network_config.dart';

class BookingUrls {
  static String bookAppointmentUrl() {
    return '${NetworkConfig.baseUrl}/patient/appointments';
  }
}
