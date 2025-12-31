import 'dart:io';
import '../../network/entities/api_request.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../entities/follow_up_chat.dart';
import '../entities/follow_up_eligibility.dart';
import '../../_shared/constants/network_config.dart';

class FollowUpChatService {
  final NetworkAdapter _networkAdapter;
  
  FollowUpChatService({NetworkAdapter? networkAdapter}) 
      : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  /// Check follow-up eligibility for a specific appointment
  Future<FollowUpEligibility> checkFollowUpEligibility(String appointmentId) async {
    final url = '${NetworkConfig.baseUrl}/follow-up-chats/appointments/$appointmentId/eligibility';
    final apiRequest = APIRequest(url);
    
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        return FollowUpEligibility.fromJson(apiResponse.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
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
        throw ServerSentException('Failed to check follow-up eligibility', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  /// Get follow-up chat for a specific appointment
  Future<FollowUpChat> getFollowUpChat(String appointmentId) async {
    final url = '${NetworkConfig.baseUrl}/follow-up-chats/appointments/$appointmentId';
    final apiRequest = APIRequest(url);
    
    try {
      final apiResponse = await _networkAdapter.get(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        return FollowUpChat.fromJson(apiResponse.data as Map<String, dynamic>);
      }
      throw Exception('Invalid response format');
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
        throw ServerSentException('Failed to load follow-up chat', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  /// Send a text message in follow-up chat
  Future<ChatMessage> sendTextMessage(int consultationId, String message) async {
    final url = '${NetworkConfig.baseUrl}/follow-up-chats/$consultationId/messages';
    final apiRequest = APIRequest(url);
    apiRequest.addParameters({
      'message': message,
      'message_type': 'text',
    });
    
    try {
      final apiResponse = await _networkAdapter.post(apiRequest);
      if (apiResponse.data is Map<String, dynamic>) {
        final data = apiResponse.data as Map<String, dynamic>;
        final messageData = data['data'] as Map<String, dynamic>? ?? {};
        return ChatMessage.fromJson(messageData);
      }
      throw Exception('Invalid response format');
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
        throw ServerSentException('Failed to send message', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  /// Send an image message in follow-up chat
  Future<ChatMessage> sendImageMessage(int consultationId, File imageFile) async {
    final url = '${NetworkConfig.baseUrl}/follow-up-chats/$consultationId/messages';
    
    try {
      final apiRequest = APIRequest(url);
      apiRequest.addParameters({
        'message_type': 'image',
        'file': imageFile,
      });
      
      final apiResponse = await _networkAdapter.uploadFile(apiRequest, imageFile);
      
      if (apiResponse.data is Map<String, dynamic>) {
        final data = apiResponse.data as Map<String, dynamic>;
        final messageData = data['data'] as Map<String, dynamic>? ?? {};
        return ChatMessage.fromJson(messageData);
      }
      throw Exception('Invalid response format');
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
        throw ServerSentException('Failed to send image', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  /// Mark messages as read
  Future<void> markMessagesAsRead(int consultationId) async {
    final url = '${NetworkConfig.baseUrl}/follow-up-chats/$consultationId/mark-read';
    final apiRequest = APIRequest(url);
    
    try {
      await _networkAdapter.post(apiRequest);
    } on NetworkFailureException {
      throw NetworkFailureException();
    } on APIException catch (exception) {
      if (exception is HTTPException) {
        // Silently fail for mark as read - not critical
        return;
      } else {
        rethrow;
      }
    }
  }
}