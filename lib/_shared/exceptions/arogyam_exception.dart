abstract class ArogyamException implements Exception {
  final String userReadableMessage;
  final String internalErrorMessage;

  ArogyamException(this.userReadableMessage, this.internalErrorMessage);
}
