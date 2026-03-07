import '../../_shared/constants/network_config.dart';
import '../../find_doctor/entities/doctor_filter.dart';

class CommonUrls {
  /// Fetch list of specializations
  static String getSpecializationsUrl() {
    return '${NetworkConfig.baseUrl}/doctors/specializations';
  }

  /// Fetch list of doctors
  static String getDoctorsUrl({
    int page = 1,
    int perPage = 10,
    String? search,
    DoctorFilter? filter,
  }) {
    String url = '${NetworkConfig.baseUrl}/doctors/featured?page=$page&per_page=$perPage';
    
    final searchQuery = search ?? filter?.searchQuery;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += '&search=$searchQuery';
    }
    
    if (filter != null) {
      url += _buildFilterParams(filter);
    }
    
    return url;
  }
  
  static String getDoctorsBySpecializationUrl(
    String specialization, {
    int page = 1,
    int perPage = 10,
    String? search,
    DoctorFilter? filter,
  }) {
    String url = '${NetworkConfig.baseUrl}/doctors/specialization/$specialization?page=$page&per_page=$perPage';
    
    final searchQuery = search ?? filter?.searchQuery;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += '&search=$searchQuery';
    }
    
    if (filter != null) {
      url += _buildFilterParams(filter);
    }
    
    return url;
  }

  /// Autocomplete search endpoint
  static String getAutocompleteUrl(String query, {int limit = 10}) {
    final encodedQuery = Uri.encodeComponent(query);
    return '${NetworkConfig.baseUrl}/search/autocomplete?q=$encodedQuery&limit=$limit';
  }

  /// Popular searches endpoint
  static String getPopularSearchesUrl() {
    return '${NetworkConfig.baseUrl}/search/popular';
  }

  /// Reverse geocode coordinates to get location details
  static String getReverseGeocodeUrl(double latitude, double longitude) {
    return '${NetworkConfig.baseUrl}/reverse-geocode?lat=$latitude&lng=$longitude';
  }

  /// Build URL parameters from filter
  static String _buildFilterParams(DoctorFilter filter) {
    final params = StringBuffer();
    
    // Add sort by
    if (filter.sortBy != null) {
      params.write('&sort_by=${filter.sortBy!.apiValue}');
    }
    
    // Add quick filters
    for (final quickFilter in filter.quickFilters) {
      params.write('&${quickFilter.apiKey}=1');
    }
    
    return params.toString();
  }
}
