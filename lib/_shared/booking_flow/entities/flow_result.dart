enum FlowResultType {
  success,
  cancelled,
  error,
}

class FlowResult<T> {
  final FlowResultType type;
  final T? data;
  final String? errorMessage;

  const FlowResult._({
    required this.type,
    this.data,
    this.errorMessage,
  });

  // Factory constructors
  factory FlowResult.success(T data) {
    return FlowResult._(
      type: FlowResultType.success,
      data: data,
    );
  }

  factory FlowResult.cancelled() {
    return FlowResult._(
      type: FlowResultType.cancelled,
    );
  }

  factory FlowResult.error(String message) {
    return FlowResult._(
      type: FlowResultType.error,
      errorMessage: message,
    );
  }

  // Convenience getters
  bool get isSuccess => type == FlowResultType.success;
  bool get isCancelled => type == FlowResultType.cancelled;
  bool get isError => type == FlowResultType.error;
}