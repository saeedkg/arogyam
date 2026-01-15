import '../../network/entities/api_request.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../entities/clinic_detail.dart';
import '../constants/clinic_urls.dart';

class ClinicService {
  final NetworkAdapter _networkAdapter;

  ClinicService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<ClinicDetail> getClinicDetail(String clinicId) async {
    final url = ClinicUrls.getClinicDetailUrl(clinicId);
    final apiRequest = APIRequest(url);

    final apiResponse = await _networkAdapter.get(apiRequest);
    final map = apiResponse.data as Map<String, dynamic>;
    final data = map['data'] as Map<String, dynamic>;

    return ClinicDetail.fromJson(data);
  }
}
