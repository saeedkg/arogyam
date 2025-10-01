


import 'arogyam_exception.dart';

class MappingException extends ArogyamException {
  static const String _USER_READABLE_MESSAGE = "Oops! Looks like something has gone wrong. Please try again.";

  MappingException(String errorMessage) : super(_USER_READABLE_MESSAGE, errorMessage);
}
