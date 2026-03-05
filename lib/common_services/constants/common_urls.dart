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

  /// Universal search endpoint
  static String getUniversalSearchUrl({
    required String query,
    String entityType = 'all',
    int? specializationId,
    String? city,
    String? state,
    String? country,
    double? latitude,
    double? longitude,
    List<String>? consultationTypes,
    bool? availableNow,
    double? minRating,
    int? minFee,
    int? maxFee,
    String sortBy = 'relevance',
    int page = 1,
    int perPage = 20,
  }) {
    final encodedQuery = Uri.encodeComponent(query);
    final params = StringBuffer('?q=$encodedQuery');

    params.write('&entity_type=$entityType');
    params.write('&page=$page');
    params.write('&per_page=$perPage');
    params.write('&sort_by=$sortBy');

    if (specializationId != null) {
      params.write('&specialization_id=$specializationId');
    }
    if (city != null && city.isNotEmpty) {
      params.write('&city=${Uri.encodeComponent(city)}');
    }
    if (state != null && state.isNotEmpty) {
      params.write('&state=${Uri.encodeComponent(state)}');
    }
    if (country != null && country.isNotEmpty) {
      params.write('&country=${Uri.encodeComponent(country)}');
    }
    if (latitude != null) {
      params.write('&latitude=$latitude');
    }
    if (longitude != null) {
      params.write('&longitude=$longitude');
    }
    if (consultationTypes != null && consultationTypes.isNotEmpty) {
      for (final type in consultationTypes) {
        params.write('&consultation_types[]=$type');
      }
    }
    if (availableNow != null) {
      params.write('&available_now=${availableNow ? '1' : '0'}');
    }
    if (minRating != null) {
      params.write('&min_rating=$minRating');
    }
    if (minFee != null) {
      params.write('&min_fee=$minFee');
    }
    if (maxFee != null) {
      params.write('&max_fee=$maxFee');
    }

    return '${NetworkConfig.baseUrl}/search${params.toString()}';
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
