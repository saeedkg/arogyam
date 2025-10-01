import 'dart:convert';
import 'dart:io';




import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../entities/api_request.dart';
import '../entities/api_response.dart';
import '../exceptions/api_exception.dart';
import '../exceptions/network_failure_exception.dart';
import '../exceptions/unexpected_response_format_exception.dart';
import 'network_adapter.dart';

class NetworkRequestExecutor implements NetworkAdapter {
  Dio dio = new Dio();

  NetworkRequestExecutor() {
    dio.interceptors.add(PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        error: true,
        compact: true,
        maxWidth: 90));
  }

  @override
  Future<APIResponse> get(APIRequest apiRequest) async {
    return executeRequest(apiRequest, 'GET');
  }

  @override
  Future<APIResponse> post(APIRequest apiRequest) async {
    return executeRequest(apiRequest, 'POST');
  }

  @override
  Future<APIResponse> postWithNonce(APIRequest apiRequest) async {
    return executeRequest(apiRequest, 'POST');
  }

  @override
  Future<APIResponse> put(APIRequest apiRequest) async {
    return executeRequest(apiRequest, 'PUT');
  }

  @override
  Future<APIResponse> delete(APIRequest apiRequest) async {
    return executeRequest(apiRequest, 'DELETE');
  }
//   NetworkRequestExecutor
//   FormData formData = FormData.fromMap({
//   'invoice': [
//   await MultipartFile.fromFile(file.path, filename: file.path.split('/').last)
//   ],
//   'invoice_number': apiRequest.parameters['invoice_number'] ?? 'INV-009736',
// });


  @override
  Future<APIResponse> uploadFile(APIRequest apiRequest, File file) async {
    if (await _isConnected() == false) throw NetworkFailureException();

    try {
      // Build FormData dynamically from parameters
      Map<String, dynamic> formDataMap = {};
      
      // Add all parameters from the request
      for (var entry in apiRequest.parameters.entries) {
        String key = entry.key;
        dynamic value = entry.value;
        
        if (value is File) {
          // Handle file uploads - await the MultipartFile creation
          formDataMap[key] = [
            await MultipartFile.fromFile(value.path, filename: value.path.split('/').last)
          ];
        } else {
          // Handle regular parameters
          formDataMap[key] = value;
        }
      }

      FormData formData = FormData.fromMap(formDataMap);
      print(formData);

      Response<String> response = await dio.post(
        apiRequest.url,
        data: formData,
        options: Options(
          headers: apiRequest.headers,
          validateStatus: (status) => status == 200,
        ),
      );
      return _processResponse(response, apiRequest);
    } on DioError catch (error) {
      throw _processError(error);
    }
  }

  Future<APIResponse> executeRequest(APIRequest apiRequest, String method) async {
    if (await _isConnected() == false) throw NetworkFailureException();

    try {
      Response<String> response = await dio.request(
        apiRequest.url,
        data: jsonEncode(apiRequest.parameters),
        options: Options(
          method: method,
          headers: apiRequest.headers,
          validateStatus: (status) => status == 200,
        ),
      );
      return _processResponse(response, apiRequest);
    } on DioError catch (error) {
      throw _processError(error);
    }
  }

  Future<bool> _isConnected() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }

  APIResponse _processResponse(Response response, APIRequest apiRequest) {
    try {
      var responseData = json.decode(response.data);
      return APIResponse(apiRequest, response.statusCode!, responseData, {});
    } catch (e) {
      throw UnexpectedResponseFormatException();
    }
  }

  APIException _processError(DioError error) {
    if (error.response == null || error.response!.statusCode == null) {
      //Something happened in setting up or sending the request that triggered an Error
      return RequestException(error.message);
    } else {
      // The request was made and the server responded with a statusCode != 200
      print("Error response data type: ${error.response!.data.runtimeType}");
      print("Error response data: ${error.response!.data}");
      
      // Try to parse the response data if it's a string
      dynamic responseData = error.response!.data;
      if (responseData is String) {
        try {
          responseData = json.decode(responseData);
          print("Parsed response data: $responseData");
        } catch (e) {
          print("Failed to parse response data as JSON: $e");
        }
      }
      
      return HTTPException(error.response!.statusCode!, responseData);
    }
  }
}
