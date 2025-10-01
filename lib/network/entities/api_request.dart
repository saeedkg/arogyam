import 'dart:core';

//import 'package:uuid/uuid.dart';

class APIRequest {
  String url;
  Map<String, dynamic> parameters = Map<String, dynamic>();
  Map<String, String> headers = Map<String, String>();
  final String requestId;

 // APIRequest(this.url) : requestId = Uuid().v1();
  APIRequest(this.url) : requestId = "sd";



  APIRequest.withId(this.url, this.requestId);

  addParameter(String key, dynamic value) {
    parameters[key] = value;
  }

  addParameters(Map<String, dynamic> params) {
    parameters.addAll(params);
  }

  addHeader(String key, String value) {
    headers[key] = value;
  }

  addHeaders(Map<String, String> headers) {
    this.headers.addAll(headers);
  }
}
