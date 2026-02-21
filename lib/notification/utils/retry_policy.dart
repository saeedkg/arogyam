/// Retry policy for handling failed operations with exponential backoff
class RetryPolicy {
  static const int maxAttempts = 3;
  static const List<int> backoffDelays = [1000, 2000, 4000]; // milliseconds

  /// Execute an operation with retry logic
  static Future<T?> executeWithRetry<T>(
    Future<T> Function() operation, {
    int maxAttempts = maxAttempts,
    List<int>? customBackoffDelays,
  }) async {
    final delays = customBackoffDelays ?? backoffDelays;
    
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        print('🔄 Attempt ${attempt + 1}/$maxAttempts');
        return await operation();
      } catch (e) {
        print('❌ Attempt ${attempt + 1} failed: $e');
        
        if (attempt == maxAttempts - 1) {
          // Last attempt failed, rethrow
          print('❌ All retry attempts exhausted');
          rethrow;
        }
        
        // Wait before retrying
        final delayMs = attempt < delays.length ? delays[attempt] : delays.last;
        print('⏳ Waiting ${delayMs}ms before retry...');
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    
    return null;
  }

  /// Execute with custom retry condition
  static Future<T?> executeWithRetryIf<T>(
    Future<T> Function() operation,
    bool Function(dynamic error) shouldRetry, {
    int maxAttempts = maxAttempts,
  }) async {
    for (int attempt = 0; attempt < maxAttempts; attempt++) {
      try {
        return await operation();
      } catch (e) {
        if (!shouldRetry(e) || attempt == maxAttempts - 1) {
          rethrow;
        }
        
        final delayMs = attempt < backoffDelays.length 
            ? backoffDelays[attempt] 
            : backoffDelays.last;
        await Future.delayed(Duration(milliseconds: delayMs));
      }
    }
    
    return null;
  }
}
