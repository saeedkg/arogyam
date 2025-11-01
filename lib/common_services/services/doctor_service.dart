import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/common_urls.dart';
import '../entities/doctor.dart';

class DoctorService {
  final NetworkAdapter _networkAdapter;

  DoctorService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Fetch list of all doctors
  Future<List<Doctor>> fetchDoctors() async {
    final apiRequest = APIRequest(CommonUrls.getDoctorsUrl());
    try {
      final res = await _networkAdapter.get(apiRequest);
      final data = res.data;

      // Expected structure: { "data": { "doctors": [ ... ] } }
      if (data is Map<String, dynamic> &&
          data['data'] != null &&
          data['data']['doctors'] is List) {
        final List list = data['data']['doctors'];
        return list.map((e) => Doctor.fromJson(e)).toList();
      }

      throw Exception('Invalid doctors response format');
    } on APIException {
      rethrow;
    }
  }
}
