

import '../../_shared/exceptions/arogyam_exception.dart';

export 'http_exception.dart';
export 'malformed_response_exception.dart';
export 'network_failure_exception.dart';
export 'request_exception.dart';
export 'server_sent_exception.dart';
export 'unauthorized_exception.dart';
export 'unexpected_response_format_exception.dart';

class APIException extends ArogyamException {
  final dynamic responseData;

  APIException(
    String userReadableMessage,
    String internalErrorMessage, {
    this.responseData,
  }) : super(userReadableMessage, internalErrorMessage);
}
