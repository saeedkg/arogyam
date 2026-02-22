import 'api_exception.dart';

class TokenInvalidException extends APIException {
  TokenInvalidException(String message)
      : super(
          message,
          'Token is invalid - user needs to login again',
        );
}
