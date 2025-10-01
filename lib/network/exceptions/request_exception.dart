import 'api_exception.dart';

class RequestException extends APIException {
  static const String _USER_READABLE_MESSAGE = "Oops! Looks like something has gone wrong. Please try again.";
  static const String _INTERNAL_MESSAGE = "";

  RequestException(String? errorMessage) : super(errorMessage ?? _USER_READABLE_MESSAGE, _INTERNAL_MESSAGE);
}
