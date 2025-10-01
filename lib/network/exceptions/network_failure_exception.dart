import 'api_exception.dart';

class NetworkFailureException extends APIException {
  static const _USER_READABLE_MESSAGE = "Please check your network connection and try again.";
  static const _INTERNAL_MESSAGE = "There is an issue with the network connection";

  NetworkFailureException() : super(_USER_READABLE_MESSAGE, _INTERNAL_MESSAGE);
}
