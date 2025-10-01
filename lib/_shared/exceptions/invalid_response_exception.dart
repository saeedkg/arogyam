


import 'arogyam_exception.dart';

class InvalidResponseException extends ArogyamException {
  static const _USER_READABLE_MESSAGE = "Oops! Looks like something has gone wrong. Please try again.";
  static const _INTERNAL_MESSAGE = "The response is invalid";

  InvalidResponseException() : super(_USER_READABLE_MESSAGE, _INTERNAL_MESSAGE);
}
