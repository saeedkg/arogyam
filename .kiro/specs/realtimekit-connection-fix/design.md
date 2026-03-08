# Design Document

## Overview

This design addresses critical connection and resource management issues in the RealtimeKit video call integration. The primary issue is that sessions are not appearing in the Cloudflare dashboard (https://dash.cloudflare.com/) after the first call, and subsequent calls fail to connect without force-closing the app. This indicates incomplete client disposal and cached state persisting between calls.

### Root Cause Analysis

1. **Incomplete Client Disposal**: The RealtimeKit client is not being fully destroyed between calls, leaving cached state and active connections
2. **Stale Connection State**: Old client instances prevent new connections from being established with Cloudflare servers
3. **Improper SDK Initialization**: Current implementation uses workarounds that bypass proper SDK lifecycle
4. **Missing Cleanup Steps**: Not waiting for leave completion before disposal, not nullifying all references
5. **Poor Logging**: Excessive print statements without structure make debugging difficult

### Key Problems Identified

1. **Sessions Not in Cloudflare Dashboard**: Client not properly connecting to Cloudflare servers due to stale state
2. **Force Close Required**: Cached client instances block new connections
3. **Workarounds in Code**: Manual state forcing instead of relying on SDK callbacks
4. **Incomplete Resource Cleanup**: Client instances and listeners persist between calls
5. **Poor Logging**: Excessive print statements without structure or log levels
6. **Version Mismatch**: Using outdated patterns not aligned with current SDK version (0.1.5+1)

## Architecture

### Component Overview

```
┌─────────────────────────────────────────────────────────┐
│                    UI Layer                              │
│         RealtimeKitVideoCallScreen                       │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              Controller Layer                            │
│      RealtimeKitVideoCallController (GetX)              │
│  - State management                                      │
│  - User action handling                                  │
│  - Error handling                                        │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│               Service Layer                              │
│           RealtimeKitService                             │
│  - SDK lifecycle management                              │
│  - Event listener implementation                         │
│  - Resource cleanup                                      │
│  - Logging                                               │
└────────────────────┬────────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────────┐
│              SDK Layer                                   │
│         realtimekit_core (0.1.5+1)                      │
│  - RealtimekitClient                                     │
│  - RtkMeetingInfo                                        │
│  - Event callbacks                                       │
└─────────────────────────────────────────────────────────┘
```

### Logging Architecture

```
┌─────────────────────────────────────────────────────────┐
│                  Logger Package                          │
│  - Structured logging with levels                        │
│  - Configurable output                                   │
│  - Production-ready                                      │
└────────────────────┬────────────────────────────────────┘
                     │
         ┌───────────┴───────────┬──────────────┐
         │                       │              │
┌────────▼────────┐  ┌──────────▼──────┐  ┌───▼────────┐
│  VideoCallLogger │  │  ServiceLogger  │  │ SDKLogger  │
│  (Controller)    │  │  (Service)      │  │ (Wrapper)  │
└──────────────────┘  └─────────────────┘  └────────────┘
```

## Components and Interfaces

### 1. Logger Utility

**File**: `lib/consultation/utils/video_call_logger.dart`

```dart
import 'package:logger/logger.dart';

class VideoCallLogger {
  static final Logger _logger = Logger(
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 5,
      lineLength: 80,
      colors: true,
      printEmojis: true,
      printTime: true,
    ),
  );

  // Log levels
  static void debug(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.d(message, error: error, stackTrace: stackTrace);
  }

  static void info(String message) {
    _logger.i(message);
  }

  static void warning(String message, [dynamic error]) {
    _logger.w(message, error: error);
  }

  static void error(String message, [dynamic error, StackTrace? stackTrace]) {
    _logger.e(message, error: error, stackTrace: stackTrace);
  }

  // Specific logging methods for video call operations
  static void logMeetingInit(String authToken, String roomName, String participantId) {
    info('Meeting Init - Room: $roomName, Participant: $participantId, Token: ${authToken.substring(0, 10)}...');
  }

  static void logMeetingJoin(String roomName) {
    info('Joining meeting room: $roomName');
  }

  static void logMeetingLeave(String roomName) {
    info('Leaving meeting room: $roomName');
  }

  static void logConnectionState(String state) {
    info('Connection state changed: $state');
  }

  static void logParticipantEvent(String event, String participantId) {
    debug('Participant event: $event for $participantId');
  }

  static void logMediaControl(String action, bool enabled) {
    info('Media control: $action = $enabled');
  }

  static void logCleanup(String component) {
    debug('Cleaning up: $component');
  }
}
```

### 2. Enhanced RealtimeKitService

**Key Design Changes:**

#### A. Proper Initialization Flow

```dart
// BEFORE (with workarounds):
_client!.init(meetingInfo);
await joinMeeting();  // Manual call
await Future.delayed(Duration(seconds: 3));  // Forced delay
_updateConnectionState(connected);  // Manual state

// AFTER (following SDK pattern):
_client!.init(meetingInfo);
// Wait for onMeetingInitCompleted callback
// Callback automatically triggers joinRoom()
// Callback updates connection state
```

#### B. Complete Resource Cleanup

The key to fixing the Cloudflare dashboard issue is ensuring complete client disposal:

```dart
class RealtimeKitService {
  RealtimekitClient? _client;
  bool _isDisposed = false;
  bool _isLeaving = false;
  
  Future<void> dispose() async {
    if (_isDisposed || _isLeaving) {
      VideoCallLogger.warning('Dispose called but already disposing/disposed');
      return;
    }
    
    _isDisposed = true;
    VideoCallLogger.info('Starting complete client disposal');
    
    try {
      // Step 1: Leave meeting if connected
      if (_client != null && _connectionState == ConnectionState.connected) {
        VideoCallLogger.info('Leaving meeting before disposal');
        _isLeaving = true;
        
        await leaveMeeting();
        
        // Wait for leave to complete (with timeout)
        await _waitForDisconnection(timeout: Duration(seconds: 5));
        
        _isLeaving = false;
        VideoCallLogger.info('Leave completed');
      }
      
      // Step 2: Remove all event listeners
      if (_client != null) {
        VideoCallLogger.debug('Removing event listeners');
        _client!.removeMeetingRoomEventListener(this);
        _client!.removeParticipantsEventListener(this);
        VideoCallLogger.debug('Event listeners removed');
      }
      
      // Step 3: Clean native listeners (critical for preventing cached state)
      if (_client != null) {
        VideoCallLogger.debug('Cleaning native listeners');
        _client!.cleanAllNativeListeners();
        VideoCallLogger.debug('Native listeners cleaned');
      }
      
      // Step 4: Close stream controllers
      VideoCallLogger.debug('Closing stream controllers');
      await _connectionStateController.close();
      await _participantEventController.close();
      VideoCallLogger.debug('Stream controllers closed');
      
      // Step 5: Nullify client reference (critical!)
      VideoCallLogger.debug('Nullifying client reference');
      _client = null;
      VideoCallLogger.info('Client reference nullified');
      
      // Step 6: Reset all state
      _connectionState = ConnectionState.disconnected;
      _isAudioEnabled = true;
      _isVideoEnabled = true;
      
      VideoCallLogger.info('✅ Complete disposal finished - ready for new connection');
      
    } catch (e, stackTrace) {
      VideoCallLogger.error('Error during disposal', e, stackTrace);
      // Force cleanup even on error
      _client = null;
      _isLeaving = false;
    }
  }
  
  Future<void> _waitForDisconnection({Duration timeout = const Duration(seconds: 5)}) async {
    if (_connectionState == ConnectionState.disconnected) {
      return;
    }
    
    final completer = Completer<void>();
    Timer? timeoutTimer;
    StreamSubscription? subscription;
    
    subscription = connectionStateStream.listen((state) {
      if (state == ConnectionState.disconnected) {
        timeoutTimer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    timeoutTimer = Timer(timeout, () {
      subscription?.cancel();
      if (!completer.isCompleted) {
        VideoCallLogger.warning('Disconnect timeout - forcing completion');
        completer.complete();
      }
    });
    
    await completer.future;
  }
}
```

**Why This Fixes the Cloudflare Dashboard Issue:**

1. **cleanAllNativeListeners()**: Clears native SDK state that was preventing new connections
2. **Nullifying _client**: Ensures no cached reference exists
3. **Waiting for leave**: Properly closes the session on Cloudflare servers
4. **Complete state reset**: No leftover state interferes with new connections

#### C. State Verification Before Initialization

Prevent cached state from blocking new connections:

```dart
Future<void> initializeMeeting({
  required String authToken,
  required String roomName,
  required String participantId,
}) async {
  VideoCallLogger.info('=== Starting Meeting Initialization ===');
  
  // CRITICAL: Verify clean state before initialization
  if (_client != null) {
    VideoCallLogger.warning('⚠️ Client already exists! Disposing before re-init...');
    await dispose();
    
    // Give SDK time to fully clean up native resources
    await Future.delayed(Duration(milliseconds: 500));
    VideoCallLogger.info('Previous client disposed, proceeding with fresh init');
  }
  
  // Verify we're starting from clean state
  if (_isDisposed) {
    VideoCallLogger.debug('Resetting disposed flag');
    _isDisposed = false;
  }
  
  if (_isLeaving) {
    VideoCallLogger.warning('Still in leaving state, resetting');
    _isLeaving = false;
  }
  
  // Reset all state to defaults
  _connectionState = ConnectionState.disconnected;
  _isAudioEnabled = true;
  _isVideoEnabled = true;
  
  VideoCallLogger.info('State verified clean, creating new client');
  
  try {
    _updateConnectionState(ConnectionState.connecting);
    
    // Create fresh client instance
    _client = RealtimekitClient();
    VideoCallLogger.info('✅ New RealtimekitClient created');
    
    // Add listeners BEFORE init
    _client!.addMeetingRoomEventListener(this);
    _client!.addParticipantsEventListener(this);
    VideoCallLogger.debug('Event listeners added');
    
    // Create meeting info
    final meetingInfo = RtkMeetingInfo(
      authToken: authToken,
      enableAudio: true,
      enableVideo: true,
    );
    
    VideoCallLogger.logMeetingInit(authToken, roomName, participantId);
    
    // Initialize - callbacks will handle the rest
    _client!.init(meetingInfo);
    VideoCallLogger.info('SDK init() called - waiting for callbacks');
    
    // NO WORKAROUNDS - let SDK callbacks handle everything
    
  } catch (e, stackTrace) {
    VideoCallLogger.error('Failed to initialize meeting', e, stackTrace);
    _updateConnectionState(ConnectionState.failed);
    throw VideoCallError.authentication(
      'Failed to initialize meeting',
      details: e.toString(),
    );
  }
}
```

**Why This Fixes the Issue:**

1. **Checks for existing client**: Prevents trying to create a new client while old one exists
2. **Forces disposal**: Ensures complete cleanup before new connection
3. **Delay after disposal**: Gives native SDK time to release resources
4. **State verification**: Ensures all flags are reset
5. **Fresh client**: New instance with no cached state

### 3. SDK Callback Flow

```
User Action: Join Meeting
         │
         ▼
Controller.initialize()
         │
         ▼
Service.initializeMeeting()
         │
         ├─► Create RealtimekitClient
         ├─► Add event listeners
         ├─► Create RtkMeetingInfo
         └─► Call client.init()
                  │
                  ▼
         ┌────────────────────┐
         │  SDK Callbacks     │
         └────────────────────┘
                  │
         ┌────────┴────────┐
         │                 │
         ▼                 ▼
onMeetingInitStarted  onMeetingInitCompleted
         │                 │
         │                 ├─► Auto call joinRoom()
         │                 │
         ▼                 ▼
Update state:        onMeetingRoomJoinStarted
connecting                 │
                           ▼
                  onMeetingRoomJoinCompleted
                           │
                           ├─► Update state: connected
                           ├─► Emit connection event
                           └─► UI shows video
```

## Data Models

### Connection State Flow

```dart
enum ConnectionState {
  disconnected,   // Initial state, after cleanup
  connecting,     // During init and join
  connected,      // Successfully joined
  reconnecting,   // Network recovery (future)
  failed,         // Error occurred
}
```

### State Transitions

```
disconnected ──init()──> connecting
                            │
                ┌───────────┴───────────┐
                │                       │
         onInitCompleted          onInitFailed
                │                       │
                ▼                       ▼
         joinRoom()                  failed
                │
        ┌───────┴───────┐
        │               │
  onJoinCompleted  onJoinFailed
        │               │
        ▼               ▼
    connected        failed
        │
    leaveRoom()
        │
        ▼
    disconnected
```

## Error Handling

### Error Categories and Recovery

```dart
class ErrorHandler {
  static void handleSDKError(dynamic error, StackTrace? stackTrace) {
    if (error is MeetingError) {
      switch (error.code) {
        case 'AUTH_FAILED':
          // Non-recoverable
          VideoCallLogger.error('Authentication failed', error, stackTrace);
          throw VideoCallError.authentication(
            'Invalid credentials',
            details: error.message,
          );
          
        case 'NETWORK_ERROR':
          // Recoverable
          VideoCallLogger.warning('Network error', error);
          throw VideoCallError.connection(
            'Network connection lost',
            details: error.message,
          );
          
        case 'ROOM_FULL':
          // Non-recoverable
          VideoCallLogger.error('Room is full', error);
          throw VideoCallError.runtime(
            'Meeting room is full',
            details: error.message,
          );
          
        default:
          VideoCallLogger.error('Unknown SDK error', error, stackTrace);
          throw VideoCallError.runtime(
            'Unexpected error',
            details: error.message,
          );
      }
    }
  }
}
```

### Retry Logic

```dart
class RetryPolicy {
  static const maxRetries = 3;
  static const retryDelay = Duration(seconds: 2);
  
  static Future<T> withRetry<T>(
    Future<T> Function() operation,
    {bool Function(dynamic)? shouldRetry}
  ) async {
    int attempts = 0;
    
    while (attempts < maxRetries) {
      try {
        return await operation();
      } catch (e) {
        attempts++;
        
        if (attempts >= maxRetries || 
            (shouldRetry != null && !shouldRetry(e))) {
          rethrow;
        }
        
        VideoCallLogger.warning(
          'Operation failed, retrying ($attempts/$maxRetries)',
          e,
        );
        
        await Future.delayed(retryDelay * attempts);
      }
    }
    
    throw Exception('Max retries exceeded');
  }
}
```

## Testing Strategy

### Unit Tests

```dart
// Test: Service cleanup
test('dispose() should clean up all resources', () async {
  final service = RealtimeKitService();
  await service.initializeMeeting(/* ... */);
  
  await service.dispose();
  
  expect(service.client, isNull);
  expect(service.connectionState, ConnectionState.disconnected);
});

// Test: Multiple initialization
test('should handle multiple init calls', () async {
  final service = RealtimeKitService();
  
  await service.initializeMeeting(/* config 1 */);
  await service.dispose();
  await service.initializeMeeting(/* config 2 */);
  
  expect(service.client, isNotNull);
});

// Test: State transitions
test('should transition states correctly', () async {
  final service = RealtimeKitService();
  final states = <ConnectionState>[];
  
  service.connectionStateStream.listen(states.add);
  
  await service.initializeMeeting(/* ... */);
  
  expect(states, contains(ConnectionState.connecting));
  expect(states, contains(ConnectionState.connected));
});
```

### Integration Tests

```dart
// Test: End-to-end call flow
testWidgets('should complete full call lifecycle', (tester) async {
  // 1. Join meeting
  await tester.tap(find.text('Join Consultation'));
  await tester.pumpAndSettle();
  
  // 2. Verify connected
  expect(find.text('Connected'), findsOneWidget);
  
  // 3. End call
  await tester.tap(find.byIcon(Icons.call_end));
  await tester.pumpAndSettle();
  
  // 4. Join again
  await tester.tap(find.text('Join Consultation'));
  await tester.pumpAndSettle();
  
  // 5. Verify second connection works
  expect(find.text('Connected'), findsOneWidget);
});
```

## Performance Considerations

### Memory Management

1. **Stream Controllers**: Always close in dispose()
2. **Event Listeners**: Remove before nulling client
3. **Native Resources**: Call cleanAllNativeListeners()
4. **Timers**: Cancel all pending timers

### Network Optimization

1. **Connection Timeout**: 10 seconds max for initial connection
2. **Retry Backoff**: Exponential backoff for retries
3. **Bandwidth Detection**: Adjust quality based on network (future)

## Security Considerations

### Token Handling

```dart
class SecureLogger {
  static String sanitizeToken(String token) {
    if (token.length <= 10) return '***';
    return '${token.substring(0, 10)}...';
  }
  
  static void logWithSanitization(String message, Map<String, dynamic> data) {
    final sanitized = Map<String, dynamic>.from(data);
    
    if (sanitized.containsKey('authToken')) {
      sanitized['authToken'] = sanitizeToken(sanitized['authToken']);
    }
    
    VideoCallLogger.debug('$message: $sanitized');
  }
}
```

### Sensitive Data

- Never log full auth tokens
- Sanitize participant IDs in production
- Clear credentials from memory after use

## Migration Path

### Phase 1: Add Logging (Non-breaking)
1. Add logger package dependency
2. Create VideoCallLogger utility
3. Add logging alongside existing print statements
4. Test logging output

### Phase 2: Fix SDK Usage (Breaking)
1. Remove workarounds from initializeMeeting()
2. Implement proper callback handling
3. Test connection flow
4. Verify dashboard sessions appear

### Phase 3: Enhance Cleanup (Critical)
1. Implement _waitForDisconnection()
2. Add state verification in initializeMeeting()
3. Test multiple call scenarios
4. Verify no memory leaks

### Phase 4: Remove Print Statements (Cleanup)
1. Replace all print() with VideoCallLogger
2. Remove debug print statements
3. Configure log levels for production
4. Final testing

## Platform-Specific Considerations

### iOS Configuration

#### Current Issue: Fake Plugin Override
The project currently uses a fake plugin override for iOS development on Windows:
```yaml
dependency_overrides:
  realtimekit_core_ios:
    path: fake_plugins/realtimekit_core_ios
```

**This override MUST be removed for iOS builds to work properly.**

#### iOS Requirements (from RealtimeKit documentation)

1. **Minimum iOS Version**: iOS 13.0+
   - Current Podfile sets iOS 15.0 ✅
   
2. **Permissions** (Info.plist):
   - `NSCameraUsageDescription` ✅ Already configured
   - `NSMicrophoneUsageDescription` ✅ Already configured
   
3. **Swift Version**: 5.0+
   - Current Podfile sets Swift 5.0 ✅
   
4. **Frameworks**: `use_frameworks!` required
   - Current Podfile has this ✅

5. **Background Modes** (if needed for background audio):
   - Add to Info.plist: `UIBackgroundModes` with `audio` and `voip`
   - Currently MISSING ⚠️

#### iOS Build Configuration

```ruby
# Podfile (already correct)
platform :ios, '15.0'
use_frameworks!
use_modular_headers!

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
      config.build_settings['SWIFT_VERSION'] = '5.0'
      config.build_settings['ENABLE_BITCODE'] = 'NO'
    end
  end
end
```

#### iOS Background Audio Support

Add to Info.plist for background audio during calls:
```xml
<key>UIBackgroundModes</key>
<array>
  <string>audio</string>
  <string>voip</string>
</array>
```

### Android Configuration

#### Requirements (from RealtimeKit documentation)

1. **Minimum SDK**: 21+ ✅ (already configured)
2. **Permissions** (AndroidManifest.xml):
   - `CAMERA` ✅
   - `RECORD_AUDIO` ✅
   - `INTERNET` ✅
   - `MODIFY_AUDIO_SETTINGS` (check if present)
   - `ACCESS_NETWORK_STATE` (check if present)

3. **ProGuard Rules** (if using code shrinking):
   ```
   -keep class com.cloudflare.realtimekit.** { *; }
   ```

## Configuration

### Logger Configuration

```dart
// Development
Logger(
  level: Level.debug,
  printer: PrettyPrinter(printEmojis: true, printTime: true),
);

// Production
Logger(
  level: Level.warning,
  printer: SimplePrinter(),
  output: FileOutput(file: logFile),
);
```

### SDK Configuration (Based on Official Documentation)

According to RealtimeKit Core documentation, the proper initialization pattern is:

```dart
// Step 1: Create client
final client = RealtimekitClient();

// Step 2: Add event listeners BEFORE init
client.addMeetingRoomEventListener(this);
client.addParticipantsEventListener(this);

// Step 3: Create meeting info
final meetingInfo = RtkMeetingInfo(
  authToken: authToken,  // JWT token from your backend
  enableAudio: true,     // Start with audio enabled
  enableVideo: true,     // Start with video enabled
);

// Step 4: Initialize (async operation, callbacks will fire)
client.init(meetingInfo);

// Step 5: Wait for onMeetingInitCompleted callback
// Step 6: In callback, call client.joinRoom()
// Step 7: Wait for onMeetingRoomJoinCompleted callback
// Step 8: Now connected and ready
```

### RealtimeKit Version Compatibility

Current version: `0.1.5+1` (resolved from `^0.1.3`)

**Important**: The pubspec.yaml shows `^0.1.3` but the actual resolved version is `0.1.5+1`. We should update the constraint to be explicit:

```yaml
realtimekit_core: ^0.1.5
```

This ensures we're using the latest stable version with bug fixes.

## Monitoring and Debugging

### Key Metrics to Log

1. **Connection Time**: Time from init() to connected
2. **Callback Delays**: Time between SDK callbacks
3. **Cleanup Duration**: Time to complete dispose()
4. **Error Frequency**: Count of each error type
5. **Retry Attempts**: Number of retries before success/failure

### Debug Mode

```dart
class VideoCallConfig {
  static bool debugMode = false;  // Set via environment or config
  
  static void enableDebugLogging() {
    debugMode = true;
    Logger.level = Level.debug;
  }
}
```

## Summary

This design addresses the root causes of connection failures:

1. **Proper SDK Lifecycle**: Follow official patterns, no workarounds
2. **Complete Cleanup**: Ensure resources are fully released between calls
3. **Structured Logging**: Replace print with proper logging framework
4. **State Management**: Rely on SDK callbacks, not manual forcing
5. **Error Handling**: Comprehensive error categorization and recovery

The implementation will be done incrementally to minimize risk and allow testing at each phase.
