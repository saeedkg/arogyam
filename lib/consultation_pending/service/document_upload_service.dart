import 'dart:io';
import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../_shared/constants/network_config.dart';

class DocumentUploadService {
  final NetworkAdapter _networkAdapter;

  DocumentUploadService({NetworkAdapter? networkAdapter}) 
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<void> uploadConsultationDocument({
    required File file,
    required String appointmentId,
    required String title,
    required String category,
    String? notes,
  }) async {
    final url = '${NetworkConfig.baseUrl}/patient/health-records';
    final apiRequest = APIRequest(url);
    
    apiRequest.addParameter('title', title);
    apiRequest.addParameter('category', category);
    apiRequest.addParameter('appointment_id', appointmentId);
    
    if (notes != null && notes.isNotEmpty) {
      apiRequest.addParameter('notes', notes);
    }
    
    apiRequest.addParameters({
      'file': file,
    });
    
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
        throw ServerSentException('Failed to upload document', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}