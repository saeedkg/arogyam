import 'dart:io';
import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../constants/health_records_urls.dart';
import '../entities/health_record.dart';

class HealthRecordsService {
  final NetworkAdapter _networkAdapter;

  HealthRecordsService.initWith(this._networkAdapter);

  HealthRecordsService() : _networkAdapter = AROGYAMAPI();

  Future<List<HealthRecord>> fetchHealthRecords() async {
    final url = HealthRecordsUrls.getHealthRecordsUrl();
    final apiRequest = APIRequest(url);
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        final map = apiResponse.data as Map<String, dynamic>;
        final list = (map['data'] as List<dynamic>? ?? const []);
        return list.map((e) => _mapToHealthRecord(e as Map<String, dynamic>)).toList();
      }
      throw Exception('Invalid response');
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        if (exception.responseData != null &&
            exception.responseData is Map<String, dynamic> &&
            (exception.responseData as Map<String, dynamic>)["message"] != null) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException('Failed to load health records', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  Future<void> uploadHealthRecord({
    required File file,
    required String title,
    required String category,
    String? notes,
  }) async {
    final url = HealthRecordsUrls.getHealthRecordsUrl();
    final apiRequest = APIRequest(url);
    apiRequest.addParameter('title', title);
    apiRequest.addParameter('category', category);
    if (notes != null && notes.isNotEmpty) {
      apiRequest.addParameter('notes', notes);
    }
    
    try {
      await _networkAdapter.uploadFile(apiRequest, file);
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        if (exception.responseData != null &&
            exception.responseData is Map<String, dynamic> &&
            (exception.responseData as Map<String, dynamic>)["message"] != null) {
          final responseMap = exception.responseData as Map<String, dynamic>;
          final message = responseMap["message"] as String;
          final errorCode = responseMap["errorCode"] ?? exception.httpCode;
          throw ServerSentException(message, errorCode);
        }
        throw ServerSentException('Failed to upload health record', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  HealthRecord _mapToHealthRecord(Map<String, dynamic> json) {
    // Parse date
    DateTime date;
    try {
      if (json['date'] != null) {
        date = DateTime.parse(json['date'] as String);
      } else if (json['created_at'] != null) {
        date = DateTime.parse(json['created_at'] as String);
      } else {
        date = DateTime.now();
      }
    } catch (e) {
      date = DateTime.now();
    }

    return HealthRecord(
      id: '${json['id']}',
      title: json['title'] as String? ?? 'Untitled Record',
      category: json['category'] as String? ?? 'General',
      notes: json['notes'] as String?,
      date: date,
      fileUrl: json['file'] as String?,
    );
  }
}
