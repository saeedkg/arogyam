import 'api_exception.dart';

class UnauthorizedException extends APIException {
  static const String _userReadableMessage = "Your session has expired. Please log in again.";
  static const String _internalMessage = "User is not authenticated (401 Unauthorized)";

  UnauthorizedException() : super(_userReadableMessage, _internalMessage);
}
