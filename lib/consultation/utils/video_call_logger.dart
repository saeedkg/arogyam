import 'package:logger/logger.dart';

/// Structured logging utility for video call operations
/// Replaces print statements with proper log levels and formatting
class VideoCallLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0, // No stack trace for normal logs
      errorMethodCount: 5, // Stack trace for errors
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
    level: Level.debug, // Set to Level.warning for production
  );

  // ============================================================================
  // General Log Levels
  // ============================================================================

  /// Debug level - detailed information for debugging
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  /// Info level - general informational messages
  static void info(String message) {
    _logger.i(message);
  }

  /// Warning level - potentially harmful situations
  static void warning(String message, [dynamic error]) {
    _logger.w(message, error: error);
  }

  /// Error level - error events that might still allow the app to continue
  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // ============================================================================
  // Specialized Video Call Logging Methods
  // ============================================================================

  /// Log meeting initialization with sanitized token
  static void logMeetingInit(
    String authToken,
    String roomName,
    String participantId,
  ) {
    final sanitizedToken = _sanitizeToken(authToken);
    info(
      'Meeting Init - Room: $roomName, Participant: $participantId, Token: $sanitizedToken',
    );
  }

  /// Log meeting join operation
  static void logMeetingJoin(String roomName) {
    info('Joining meeting room: $roomName');
  }

  /// Log meeting leave operation
  static void logMeetingLeave(String roomName) {
    info('Leaving meeting room: $roomName');
  }

  /// Log connection state changes
  static void logConnectionState(String state) {
    info('Connection state changed: $state');
  }

  /// Log participant events (join, leave, video/audio updates)
  static void logParticipantEvent(String event, String participantId) {
    debug('Participant event: $event for $participantId');
  }

  /// Log media control actions (audio/video toggle)
  static void logMediaControl(String action, bool enabled) {
    info('Media control: $action = $enabled');
  }

  /// Log cleanup operations
  static void logCleanup(String component) {
    debug('Cleaning up: $component');
  }

  /// Log SDK callback events
  static void logCallback(String callbackName, [String? details]) {
    if (details != null) {
      debug('SDK Callback: $callbackName - $details');
    } else {
      debug('SDK Callback: $callbackName');
    }
  }

  /// Log disposal operations
  static void logDisposal(String step) {
    debug('Disposal: $step');
  }

  // ============================================================================
  // Security - Token Sanitization
  // ============================================================================

  /// Sanitize auth token for logging (show only first 10 characters)
  static String _sanitizeToken(String token) {
    if (token.isEmpty) return '(empty)';
    if (token.length <= 10) return '***';
    return '${token.substring(0, 10)}...';
  }

  /// Log with sanitized sensitive data
  static void logWithSanitization(
    String message,
    Map<String, dynamic> data,
  ) {
    final sanitized = Map<String, dynamic>.from(data);

    // Sanitize auth token if present
    if (sanitized.containsKey('authToken')) {
      sanitized['authToken'] = _sanitizeToken(sanitized['authToken']);
    }

    // Sanitize any other sensitive fields
    if (sanitized.containsKey('token')) {
      sanitized['token'] = _sanitizeToken(sanitized['token']);
    }

    debug('$message: $sanitized');
  }

  // ============================================================================
  // Configuration
  // ============================================================================

  /// Set log level (use Level.warning for production)
  static void setLogLevel(Level level) {
    Logger.level = level;
  }

  /// Enable debug logging
  static void enableDebugLogging() {
    Logger.level = Level.debug;
    info('Debug logging enabled');
  }

  /// Disable debug logging (production mode)
  static void disableDebugLogging() {
    Logger.level = Level.warning;
    info('Debug logging disabled - production mode');
  }
}
