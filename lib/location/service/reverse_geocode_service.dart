import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../_shared/constants/network_config.dart';
import 'dart:developer' as developer;

class ReverseGeocodeService {
  /// Reverse geocode coordinates to get city name
  /// Returns city name or null if failed
  Future<String?> getCityFromCoordinates(double latitude, double longitude) async {
    try {
      developer.log(
        '🌍 ReverseGeocodeService: Fetching city for lat=$latitude, lng=$longitude',
        name: 'ReverseGeocodeService',
      );

      final url = '${NetworkConfig.baseUrl}/reverse-geocode?lat=$latitude&lng=$longitude';
      
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['data'] != null) {
          final city = data['data']['city'] as String?;
          
          if (city != null && city.isNotEmpty) {
            developer.log(
              '✅ ReverseGeocodeService: City found: $city',
              name: 'ReverseGeocodeService',
            );
            return city;
          }
        }
      }

      developer.log(
        '⚠️ ReverseGeocodeService: Failed to get city (status: ${response.statusCode})',
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
}
