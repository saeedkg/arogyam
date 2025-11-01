import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/common_urls.dart';
import '../entities/specialization.dart';

class SpecializationService {
  final NetworkAdapter _networkAdapter;

  SpecializationService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Fetch list of all specializations
  Future<List<Specialization>> fetchSpecializations() async {
    final apiRequest = APIRequest(CommonUrls.getSpecializationsUrl());
    try {
      final res = await _networkAdapter.get(apiRequest);
      final data = res.data;

      // Expected structure: { "data": { "specializations": [ ... ] } }
      if (data is Map<String, dynamic> &&
          data['data'] != null &&
          data['data']['specializations'] is List) {
        final List list = data['data']['specializations'];
        return list.map((e) => Specialization.fromJson(e)).toList();
      }

      throw Exception('Invalid specializations response format');
    } on APIException {
      rethrow;
    }
  }
}
