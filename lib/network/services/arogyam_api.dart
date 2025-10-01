import 'dart:convert';
import 'dart:io';


import '../../auth/user_management/service/auth_token_provider.dart';
import '../entities/api_request.dart';
import '../entities/api_response.dart';
import '../exceptions/api_exception.dart';
import 'arogyam_api_response_processor.dart';
import 'network_adapter.dart';
import 'network_request_executor.dart';





class AROGYAMAPI implements NetworkAdapter {
  //late DeviceInfoProvider _deviceInfo;
  late AuthTokenProvider _accessTokenProvider;
 // late NonceProvider _nonceProvider;
  late NetworkAdapter _networkAdapter;

  AROGYAMAPI() {
    //this._deviceInfo = DeviceInfoProvider();
    this._accessTokenProvider = AuthTokenProvider();
    //this._nonceProvider = NonceProvider();
    this._networkAdapter = NetworkRequestExecutor();
  }

  AROGYAMAPI.initWith( this._networkAdapter);

  @override
  Future<APIResponse> get(APIRequest apiRequest, {bool forceRefresh = false}) async {
    apiRequest.addHeaders(await _buildWPHeaders(forceRefresh: forceRefresh));
    try {
      var apiResponse = await _networkAdapter.get(apiRequest);
      return _processResponse(apiResponse, apiRequest);
    } on APIException catch (exception) {
      if (_shouldRefreshTokenOnException(exception)) {
        return get(apiRequest, forceRefresh: true);
      } else {
        throw exception;
      }
    }
  }

  @override
  Future<APIResponse> put(APIRequest apiRequest, {bool forceRefresh = false}) async {
    apiRequest.addHeaders(await _buildWPHeaders(forceRefresh: forceRefresh));
    try {
      var apiResponse = await _networkAdapter.put(apiRequest);
      return _processResponse(apiResponse, apiRequest);
    } on APIException catch (exception) {
      if (_shouldRefreshTokenOnException(exception)) {
        return put(apiRequest, forceRefresh: true);
      } else {
        throw exception;
      }
    }
  }

  @override
  Future<APIResponse> post(APIRequest apiRequest, {bool forceRefresh = false}) async {
    apiRequest.addHeaders(await _buildWPHeaders(forceRefresh: forceRefresh));
    try {
      var apiResponse = await _networkAdapter.post(apiRequest);
      return _processResponse(apiResponse, apiRequest);
    } on APIException catch (exception) {
      if (_shouldRefreshTokenOnException(exception)) {
        return post(apiRequest, forceRefresh: true);
      } else {
        throw exception;
      }
    }
  }

  @override
  Future<APIResponse> uploadFile(APIRequest apiRequest, File file, {bool forceRefresh = false}) async {
    apiRequest.addHeaders(await _buildWPHeaders(forceRefresh: forceRefresh));
    try {
      var apiResponse = await _networkAdapter.uploadFile(apiRequest, file);
      return _processResponse(apiResponse, apiRequest);
    } on APIException catch (exception) {
      if (_shouldRefreshTokenOnException(exception)) {
        return uploadFile(apiRequest, file, forceRefresh: true);
      } else {
        throw exception;
      }
    }
  }

 

  @override
  Future<APIResponse> delete(APIRequest apiRequest, {bool forceRefresh = false}) async {
    apiRequest.addHeaders(await _buildWPHeaders(forceRefresh: forceRefresh));
    try {
      var apiResponse = await _networkAdapter.delete(apiRequest);
      return _processResponse(apiResponse, apiRequest);
    } on APIException catch (exception) {
      if (_shouldRefreshTokenOnException(exception)) {
        return delete(apiRequest, forceRefresh: true);
      } else {
        throw exception;
      }
    }
  }

  Future<Map<String, String>> _buildWPHeaders({bool forceRefresh = false}) async {
    var headers = Map<String, String>();
    headers['Content-Type'] = 'application/json';
   // headers['X-WallPost-Device-ID'] = await _deviceInfo.getDeviceId();
   // headers['X-WallPost-App-ID'] = AppId.appId;
   // String authToken ="Bearer 7|fe65AQLbufhacuKXtJaHtTSsTZVyFBYzXOrfYIxh207ab479";

    var authToken = await _accessTokenProvider.getToken();
    if (authToken != null) {
      headers['Authorization'] ="Bearer $authToken";
    }
    return headers;
  }

  APIResponse _processResponse(APIResponse response, APIRequest apiRequest) {
    var responseData = AROGYAMAPIResponseProcessor().processResponseNew(response);
    return APIResponse(apiRequest, response.statusCode, responseData, {});
  }

  bool _shouldRefreshTokenOnException(APIException apiException) {
    if (apiException is HTTPException) {
      try {
        var responseData = json.decode(apiException.responseData);
        var responseMap = responseData as Map<String, dynamic>;
        var errorCode = responseMap['code'];
        if (errorCode == 1022) return true;
      } catch (e) {
        //ignore exception as the response data is optional
      }
    }
    return false;
  }
  
  @override
  Future<APIResponse> postWithNonce(APIRequest apiRequest) {
    // TODO: implement postWithNonce
    throw UnimplementedError();
  }
}
