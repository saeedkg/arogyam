import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/appointment_urls.dart';
import '../entities/appointemet_detail.dart';
import '../entities/appointment.dart';

class AppointmentsService {
  final NetworkAdapter _networkAdapter;
  final int _perPage = 10;
  int _pageNumber = 1;
  bool _didReachListEnd = false;
  bool isLoading = false;
  String? _currentPatientId;

  AppointmentsService.initWith(this._networkAdapter);

  AppointmentsService() : _networkAdapter = AROGYAMAPI();

  /// Fetch list of appointments with pagination
  Future<List<Appointment>> fetchAppointments({
    bool reset = false,
    String? patientId,
  }) async {
    if (reset) {
      _pageNumber = 1;
      _didReachListEnd = false;
      _currentPatientId = patientId;
    }

    // Use current patient ID if no new one provided
    final activePatientId = _currentPatientId ?? patientId;

    // Build URL with pagination parameters appended
    final url = AppointmentsUrls.getAppointmentsUrl(
      page: _pageNumber,
      perPage: _perPage,
      patientId: activePatientId,
    );
    
    final apiRequest = APIRequest(url);

    isLoading = true;
    try {
      final res = await _networkAdapter.get(apiRequest);
      isLoading = false;
      
      final data = res.data;

      // Expected structure: { "data": { "data": [ ... ] } }
      if (data is Map<String, dynamic> &&
          data['data'] != null &&
          data['data']['data'] is List) {
        final List list = data['data']['data'];
        final appointments = list.map((e) => Appointment.fromJson(e)).toList();
        _updatePaginationRelatedData(appointments.length);
        return appointments;
      }

      _updatePaginationRelatedData(0);
      return [];
    } on NetworkFailureException {
      isLoading = false;
      throw NetworkFailureException();
    } on APIException catch (exception) {
      isLoading = false;
      if (exception is HTTPException) {
        final responseMap = exception.responseData;
        if (responseMap != null &&
            responseMap is Map<String, dynamic> &&
            responseMap["message"] != null) {
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException(
            'Failed to load appointments', exception.httpCode);
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
    _currentPatientId = null;
  }

  /// Fetch single appointment detail by ID
  Future<AppointmentDetail> fetchAppointmentDetail(int id) async {
    final apiRequest =
    APIRequest(AppointmentsUrls.getAppointmentDetailUrl(id));
    try {
      final res = await _networkAdapter.get(apiRequest);
      final data = res.data;

      // Expected structure: { "data": { ... } }
      if (data is Map<String, dynamic> && data['data'] != null) {
        return AppointmentDetail.fromJson(data['data']);
      }

      throw Exception('Invalid appointment detail response format');
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        final responseMap = exception.responseData;
        if (responseMap != null &&
            responseMap is Map<String, dynamic> &&
            responseMap["message"] != null) {
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException(
            'Failed to load appointment detail', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}
