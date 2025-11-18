import '../../_shared/constants/network_config.dart';
import '../entities/doctor_filter.dart';

class DoctorUrls {
  static String getDoctorsListUrl({
    int page = 1,
    int perPage = 10,
    String? search,
    DoctorFilter? filter,
  }) {
    String url = '${NetworkConfig.baseUrl}/patient/doctors/featured?page=$page&per_page=$perPage';
    
    // Add search from parameter or filter
    final searchQuery = search ?? filter?.searchQuery;
    if (searchQuery != null && searchQuery.isNotEmpty) {
      url += '&search=$searchQuery';
    }
    
    // Add filter parameters if filter is provided
    if (filter != null) {
      url += _buildFilterParams(filter);
    }
    
    return url;
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

  static String getDoctorDetailUrl(String id) {
    return '${NetworkConfig.baseUrl}/patient/doctors/$id';
  }

  static String getDoctorSlotsUrl(String id, String date) {
    return '${NetworkConfig.baseUrl}/patient/doctors/$id/slots?date=$date';
  }
}


