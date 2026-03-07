import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../common_services/constants/common_urls.dart';
import 'dart:developer' as developer;

class ReverseGeocodeService {
  final NetworkAdapter _networkAdapter;

  ReverseGeocodeService({NetworkAdapter? networkAdapter})
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Reverse geocode coordinates to get full address
  /// Returns full address string or null if failed
  Future<String?> getCityFromCoordinates(
      double latitude, double longitude) async {
    try {
      developer.log(
        '🌍 ReverseGeocodeService: Fetching address for lat=$latitude, lng=$longitude',
        name: 'ReverseGeocodeService',
      );

      final url = CommonUrls.getReverseGeocodeUrl(latitude, longitude);
      final apiRequest = APIRequest(url);

      final res = await _networkAdapter.get(apiRequest);
      return _parseReverseGeocodeResponse(res.data);
    } on NetworkFailureException {
      developer.log(
        '❌ ReverseGeocodeService: Network failure',
        name: 'ReverseGeocodeService',
      );
      return null;
    } on APIException catch (exception) {
      developer.log(
        '❌ ReverseGeocodeService: API Exception: $exception',
        name: 'ReverseGeocodeService',
      );
      return null;
    } catch (e) {
      developer.log(
        '❌ ReverseGeocodeService: Error: $e',
        name: 'ReverseGeocodeService',
      );
      return null;
    }
  }

  /// Parse reverse geocode response
  /// Expected response structure:
  /// {
  ///   "success": true,
  ///   "message": "Coordinates reverse geocoded successfully",
  ///   "address": "Anganwadi, Airport Road, Kozhikode, Kerala, 673645, India",
  ///   "coordinates": { "latitude": 11.2620648, "longitude": 76.0069567 }
  /// }
  String? _parseReverseGeocodeResponse(dynamic data) {
    if (data is! Map<String, dynamic>) {
      developer.log(
        '⚠️ ReverseGeocodeService: Invalid response format',
        name: 'ReverseGeocodeService',
      );
      return null;
    }

    final map = data;

    // Handle success response structure with address field
    if (map['success'] == true && map['address'] != null) {
      final address = map['address'] as String?;

      if (address != null && address.isNotEmpty) {
        developer.log(
          '✅ ReverseGeocodeService: Address found: $address',
          name: 'ReverseGeocodeService',
        );
        return address;
      }
    }

    developer.log(
      '⚠️ ReverseGeocodeService: Failed to get address from response',
      name: 'ReverseGeocodeService',
    );
    return null;
  }
}
