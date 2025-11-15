import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../entities/doctor_list_item.dart';
import '../constants/doctor_urls.dart';
import '../../common_services/constants/common_urls.dart';

class DoctorsApiService {
  final NetworkAdapter _networkAdapter;
  final int _perPage = 10;
  int _pageNumber = 1;
  bool _didReachListEnd = false;
  bool isLoading = false;
  String? _currentSpecialization;
  String? _currentSearchQuery;

  DoctorsApiService.initWith(this._networkAdapter);

  DoctorsApiService() : _networkAdapter = AROGYAMAPI();

  Future<List<DoctorListItem>> fetchDoctorsList({bool reset = false, String? searchQuery, String? specialization}) async {
    if (reset) {
      _pageNumber = 1;
      _didReachListEnd = false;
      _currentSpecialization = specialization;
      _currentSearchQuery = searchQuery;
    }

    final url = _currentSpecialization != null && _currentSpecialization != 'All'
        ? CommonUrls.getDoctorsBySpecializationUrl(
            _currentSpecialization!,
            page: _pageNumber,
            perPage: _perPage,
            search: _currentSearchQuery,
          )
        : DoctorUrls.getDoctorsListUrl(
            page: _pageNumber,
            perPage: _perPage,
            search: _currentSearchQuery,
          );
    
    final apiRequest = APIRequest(url);

    isLoading = true;
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      isLoading = false;
      
      if (apiResponse.data is Map<String, dynamic>) {
        final map = apiResponse.data as Map<String, dynamic>;
        // Handle different response structures
        List<dynamic> list;
        if (map['data'] is List) {
          list = map['data'] as List<dynamic>;
        } else if (map['data'] != null && map['data']['doctors'] is List) {
          list = map['data']['doctors'] as List<dynamic>;
        } else if (map['doctors'] is List) {
          list = map['doctors'] as List<dynamic>;
        } else {
          list = [];
        }
        
        final doctors = list.map((e) => _mapToListItem(e as Map<String, dynamic>)).toList();
        _updatePaginationRelatedData(doctors.length);
        return doctors;
      }
      _updatePaginationRelatedData(0);
      return [];
    } on NetworkFailureException {
      isLoading = false;
      throw NetworkFailureException();
    } on APIException catch (exception) {
      isLoading = false;
      if (exception is HTTPException) {
        if (exception.responseData != null &&
            exception.responseData is Map<String, dynamic> &&
            (exception.responseData as Map<String, dynamic>)["message"] != null) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException('Failed to load doctors', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  void _updatePaginationRelatedData(int noOfItemsReceived) {
    if (noOfItemsReceived > 0) {
      _pageNumber += 1;
    }
    if (noOfItemsReceived < _perPage) {
      _didReachListEnd = true;
    }
  }

  bool get didReachListEnd => _didReachListEnd;
  int getCurrentPageNumber() => _pageNumber;

  void reset() {
    _pageNumber = 1;
    _didReachListEnd = false;
    isLoading = false;
    _currentSpecialization = null;
    _currentSearchQuery = null;
  }

  // Deprecated - kept for backward compatibility
  Future<List<DoctorListItem>> fetchDoctorsBySpecialization(String specialization) async {
    return fetchDoctorsList(reset: true, specialization: specialization);
  }

  DoctorListItem _mapToListItem(Map<String, dynamic> json) {
    // Minimal mapping for current UI needs
    final user = json['user'] as Map<String, dynamic>?;
    final specs = (json['specializations'] as List<dynamic>? ?? const []);
    final firstSpec = specs.isNotEmpty ? (specs.first as Map<String, dynamic>?) : null;
    final specializationName = (firstSpec != null ? (firstSpec['name'] as String?) : null) ?? 'General';
    final ratingStr = json['average_rating']?.toString();
    final rating = double.tryParse(ratingStr ?? '0') ?? 0.0;
    final reviews = (json['total_ratings'] is int) ? json['total_ratings'] as int : int.tryParse('${json['total_ratings'] ?? 0}') ?? 0;

    return DoctorListItem(
      id: '${json['id']}',
      name: (user != null ? (user['name'] as String?) : null) ?? 'Doctor',
      specialization: specializationName,
      hospital: 'Calicut',
      imageUrl: 'https://i.pravatar.cc/150?img=10',
      rating: rating,
      reviews: reviews,
      favorite: false,
    );
  }
}


