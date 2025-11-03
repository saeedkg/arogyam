import '../../network/entities/api_request.dart';
import '../../network/services/arogyam_api.dart';
import '../../network/services/network_adapter.dart';
import '../../network/exceptions/api_exception.dart';
import '../../network/exceptions/http_exception.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../constants/family_member_url.dart';
import '../entities/FamilyMember.dart';

class FamilyMemberService {
  final NetworkAdapter _networkAdapter;
  FamilyMemberService({NetworkAdapter? networkAdapter}) : _networkAdapter = networkAdapter ?? AROGYAMAPI();

  Future<List<FamilyMember>> getFamilyMembers() async {
    final apiRequest = APIRequest(FamilyMemberUrls.getFamilyMembersUrl());
    try {
      final response = await _networkAdapter.get(apiRequest);
      final map = response.data as Map<String, dynamic>;
      final list = (map['data'] as List<dynamic>? ?? const []);
      return list.map((e) => FamilyMember.fromJson(e as Map<String, dynamic>)).toList();
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
        throw ServerSentException('Failed to fetch family members', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }

  Future<FamilyMember> addFamilyMember(FamilyMember member) async {
    final apiRequest = APIRequest(FamilyMemberUrls.getFamilyMembersUrl());
    apiRequest.addParameters(member.toCreatePayload());
    try {
      final response = await _networkAdapter.post(apiRequest);
      final map = response.data as Map<String, dynamic>;
      final data = (map['data'] as Map<String, dynamic>);
      return FamilyMember.fromJson(data);
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
        throw ServerSentException('Failed to add family member', exception.httpCode);
      } else {
        rethrow;
      }
    }
  }
}


