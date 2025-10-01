import 'api_request.dart';

class APIResponse {
  final APIRequest apiRequest;
  final int statusCode;
  final dynamic data;
  final Map<String, dynamic> metaData;

  APIResponse(this.apiRequest, this.statusCode, this.data, this.metaData);
}
