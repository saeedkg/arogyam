enum VideoCallErrorType {
  authentication,
  connection,
  permission,
  runtime,
}

class VideoCallError {
  final VideoCallErrorType type;
  final String message;
  final String? technicalDetails;
  final bool isRecoverable;

  VideoCallError({
    required this.type,
    required this.message,
    this.technicalDetails,
    this.isRecoverable = false,
  });

  /// Get user-friendly error message based on error type
  String getUserMessage() {
    switch (type) {
      case VideoCallErrorType.authentication:
        return 'Unable to authenticate. Please try again.';
      case VideoCallErrorType.connection:
        return 'Connection failed. Please check your internet.';
      case VideoCallErrorType.permission:
        return 'Camera or microphone permission required.';
      case VideoCallErrorType.runtime:
        return 'An unexpected error occurred.';
    }
  }

  /// Create authentication error
  factory VideoCallError.authentication(String message, {String? details}) {
    return VideoCallError(
      type: VideoCallErrorType.authentication,
      message: message,
      technicalDetails: details,
      isRecoverable: false,
    );
  }

  /// Create connection error
  factory VideoCallError.connection(String message, {String? details}) {
    return VideoCallError(
      type: VideoCallErrorType.connection,
      message: message,
      technicalDetails: details,
      isRecoverable: true,
    );
  }

  /// Create permission error
  factory VideoCallError.permission(String message, {String? details}) {
    return VideoCallError(
      type: VideoCallErrorType.permission,
      message: message,
      technicalDetails: details,
      isRecoverable: true,
    );
  }

  /// Create runtime error
  factory VideoCallError.runtime(String message, {String? details}) {
    return VideoCallError(
      type: VideoCallErrorType.runtime,
      message: message,
      technicalDetails: details,
      isRecoverable: false,
    );
  }

  @override
  String toString() {
    return 'VideoCallError(type: $type, message: $message, details: $technicalDetails)';
  }
}
