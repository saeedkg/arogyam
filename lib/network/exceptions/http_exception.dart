import 'api_exception.dart';

class HTTPException extends APIException {
  static const String _USER_READABLE_MESSAGE = "Oops! Looks like something has gone wrong. Please try again.";
  static const String _INTERNAL_MESSAGE = "Request failed with HTTP error code: ";
  final int httpCode;

  HTTPException(
    this.httpCode,
    dynamic responseData,
  ) : super(_USER_READABLE_MESSAGE, '$_INTERNAL_MESSAGE $httpCode', responseData: responseData);
}
