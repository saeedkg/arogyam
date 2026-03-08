import 'dart:async';
import 'package:realtimekit_core/realtimekit_core.dart';
import '../entities/connection_state.dart' as app;
import '../entities/video_call_error.dart';
import '../entities/participant_event.dart';
import '../utils/video_call_logger.dart';

/// RealtimeKit service for managing video call connections
/// 
/// This service handles the complete lifecycle of RealtimeKit video calls:
/// - Initialization and connection to Cloudflare servers
/// - Meeting join/leave operations
/// - Audio/video controls
/// - Event handling and state management
/// - Complete resource cleanup between calls
class RealtimeKitService extends RtkMeetingRoomEventListener
    implements RtkParticipantsEventListener {
  RealtimekitClient? _client;

  // State flags
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  bool _isDisposed = false;
  bool _isLeaving = false;
  app.ConnectionState _connectionState = app.ConnectionState.disconnected;

  // Stream controllers - will be recreated if closed
  late StreamController<app.ConnectionState> _connectionStateController;
  late StreamController<ParticipantEvent> _participantEventController;

  // Getters
  bool get isAudioEnabled => _isAudioEnabled;
  bool get isVideoEnabled => _isVideoEnabled;
  app.ConnectionState get connectionState => _connectionState;
  Stream<app.ConnectionState> get connectionStateStream {
    _ensureStreamControllersOpen();
    return _connectionStateController.stream;
  }
  Stream<ParticipantEvent> get participantEventStream {
    _ensureStreamControllersOpen();
    return _participantEventController.stream;
  }
  RealtimekitClient? get client => _client;
  RtkSelfParticipant? get localUser => _client?.localUser;
  RtkParticipants? get participants => _client?.participants;

  RealtimeKitService() {
    _initializeStreamControllers();
  }

  /// Initialize or reinitialize stream controllers
  void _initializeStreamControllers() {
    _connectionStateController = StreamController<app.ConnectionState>.broadcast();
    _participantEventController = StreamController<ParticipantEvent>.broadcast();
  }

  /// Ensure stream controllers are open, recreate if closed
  void _ensureStreamControllersOpen() {
    if (_connectionStateController.isClosed) {
      VideoCallLogger.debug('Recreating closed connection state controller');
      _connectionStateController = StreamController<app.ConnectionState>.broadcast();
    }
    if (_participantEventController.isClosed) {
      VideoCallLogger.debug('Recreating closed participant event controller');
      _participantEventController = StreamController<ParticipantEvent>.broadcast();
    }
  }

  /// Initialize meeting with credentials
  /// 
  /// This method:
  /// 1. Verifies no previous client exists (disposes if found)
  /// 2. Recreates stream controllers if needed
  /// 3. Creates a fresh RealtimekitClient instance
  /// 4. Adds event listeners before initialization
  /// 5. Calls SDK init() and waits for callbacks
  /// 
  /// According to RealtimeKit documentation:
  /// https://pub.dev/documentation/realtimekit_core/latest/
  /// The proper flow is: create client -> add listeners -> init() -> wait for callbacks
  Future<void> initializeMeeting({
    required String authToken,
    required String roomName,
    required String participantId,
  }) async {
    VideoCallLogger.info('=== Starting Meeting Initialization ===');
    
    try {
      // CRITICAL: Ensure stream controllers are open FIRST
      // This must happen before any listeners are set up
      _ensureStreamControllersOpen();
      VideoCallLogger.debug('Stream controllers verified/recreated');
      
      // CRITICAL: Verify clean state before initialization
      // This prevents cached state from blocking Cloudflare dashboard sessions
      if (_client != null) {
        VideoCallLogger.warning('⚠️ Client already exists! Disposing before re-init...');
        await dispose();
        
        // Recreate stream controllers after disposal
        _ensureStreamControllersOpen();
        VideoCallLogger.debug('Stream controllers recreated after disposal');
        
        // Give SDK time to fully clean up native resources
        // This is critical for ensuring the next connection appears in Cloudflare dashboard
        await Future.delayed(const Duration(milliseconds: 500));
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
      _connectionState = app.ConnectionState.disconnected;
      _isAudioEnabled = true;
      _isVideoEnabled = true;
      
      VideoCallLogger.info('State verified clean, creating new client');
      
      // Update state to connecting
      _updateConnectionState(app.ConnectionState.connecting);
      
      // Step 1: Create fresh client instance
      _client = RealtimekitClient();
      VideoCallLogger.info('✅ New RealtimekitClient created');
      
      // Step 2: Add event listeners BEFORE init (per SDK documentation)
      _client!.addMeetingRoomEventListener(this);
      _client!.addParticipantsEventListener(this);
      VideoCallLogger.debug('Event listeners added');
      VideoCallLogger.debug('This service instance: ${this.hashCode}');
      VideoCallLogger.debug('Client instance: ${_client.hashCode}');
      
      // Step 3: Create meeting info with credentials
      final meetingInfo = RtkMeetingInfo(
        authToken: authToken,
        enableAudio: true,
        enableVideo: true,
      );
      
      VideoCallLogger.logMeetingInit(authToken, roomName, participantId);
      
      // Step 4: Initialize - SDK callbacks will handle the rest
      // Per documentation: init() is async and triggers callbacks
      // - onMeetingInitStarted() - init begins
      // - onMeetingInitCompleted() - init done, ready to join
      // - onMeetingInitFailed() - init failed
      _client!.init(meetingInfo);
      VideoCallLogger.info('SDK init() called - waiting for callbacks');
      
      // NO WORKAROUNDS - Let SDK callbacks handle everything
      // The onMeetingInitCompleted callback will automatically call joinRoom()
      
    } catch (e, stackTrace) {
      VideoCallLogger.error('Failed to initialize meeting', e, stackTrace);
      _updateConnectionState(app.ConnectionState.failed);
      throw VideoCallError.authentication(
        'Failed to initialize meeting',
        details: e.toString(),
      );
    }
  }

  // ============================================================================
  // RtkMeetingRoomEventListener implementations
  // These callbacks are triggered by the SDK during meeting lifecycle
  // ============================================================================

  @override
  void onMeetingInitStarted() {
    VideoCallLogger.info('SDK Callback: onMeetingInitStarted - Init started');
    _updateConnectionState(app.ConnectionState.connecting);
  }

  @override
  void onMeetingInitCompleted() {
    VideoCallLogger.info('SDK Callback: onMeetingInitCompleted - Init completed');
    VideoCallLogger.info('Auto-joining meeting room...');
    
    // Automatically join the room after initialization completes
    // This is the proper flow per RealtimeKit documentation
    joinMeeting();
  }

  @override
  void onMeetingInitFailed(MeetingError error) {
    VideoCallLogger.error('SDK Callback: onMeetingInitFailed', error);
    VideoCallLogger.error('Error message: ${error.message}');
    _updateConnectionState(app.ConnectionState.failed);
  }

  @override
  void onMeetingRoomJoinStarted() {
    VideoCallLogger.info('SDK Callback: onMeetingRoomJoinStarted - Join started');
    _updateConnectionState(app.ConnectionState.connecting);
  }

  @override
  void onMeetingRoomJoinCompleted() {
    VideoCallLogger.info('SDK Callback: onMeetingRoomJoinCompleted - Successfully joined!');
    VideoCallLogger.info('✅ Session should now appear in Cloudflare dashboard');
    _updateConnectionState(app.ConnectionState.connected);

    // Log participant info for debugging
    Future.delayed(const Duration(milliseconds: 500), () {
      if (_client != null) {
        final activeCount = _client!.participants.active.length;
        final joinedCount = _client!.participants.joined.length;
        VideoCallLogger.debug('Participants - Active: $activeCount, Joined: $joinedCount');
        
        for (var p in _client!.participants.active) {
          VideoCallLogger.debug('Active: ${p.name} (ID: ${p.id}, Video: ${p.videoEnabled}, Audio: ${p.audioEnabled})');
        }
      }
    });
  }

  @override
  void onMeetingRoomJoinFailed(MeetingError error) {
    VideoCallLogger.error('SDK Callback: onMeetingRoomJoinFailed', error);
    VideoCallLogger.error('Error message: ${error.message}');
    _updateConnectionState(app.ConnectionState.failed);
  }

  @override
  void onMeetingRoomLeaveStarted() {
    VideoCallLogger.info('SDK Callback: onMeetingRoomLeaveStarted - Leave started');
    _updateConnectionState(app.ConnectionState.disconnected);
  }

  @override
  void onMeetingRoomLeaveCompleted() {
    VideoCallLogger.info('SDK Callback: onMeetingRoomLeaveCompleted - Left room');
    VideoCallLogger.info('Session closed in Cloudflare dashboard');
    _updateConnectionState(app.ConnectionState.disconnected);
  }

  // ============================================================================
  // RtkParticipantsEventListener implementations
  // These callbacks are triggered when participants join/leave or change state
  // ============================================================================

  @override
  void onParticipantJoin(RtkMeetingParticipant participant) {
    VideoCallLogger.logParticipantEvent('joined', participant.id);
    VideoCallLogger.debug('Participant: ${participant.name}, Video: ${participant.videoEnabled}');
    
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.join,
      ),
    );
  }

  @override
  void onParticipantLeave(RtkMeetingParticipant participant) {
    VideoCallLogger.logParticipantEvent('left', participant.id);
    
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.leave,
      ),
    );
  }

  @override
  void onVideoUpdate(RtkRemoteParticipant participant, bool videoEnabled) {
    VideoCallLogger.debug('Video update: ${participant.name} = $videoEnabled');
    
    // Force UI update when video state changes
    _connectionStateController.add(_connectionState);
    
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.videoUpdate,
      ),
    );
  }

  @override
  void onAudioUpdate(RtkRemoteParticipant participant, bool audioEnabled) {
    VideoCallLogger.debug('Audio update: ${participant.name} = $audioEnabled');
    
    // Force UI update when audio state changes
    _connectionStateController.add(_connectionState);
    
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.audioUpdate,
      ),
    );
  }

  @override
  void onActiveParticipantsChanged(List<RtkMeetingParticipant> active) {
    VideoCallLogger.debug('Active participants changed: ${active.length}');
  }

  @override
  void onActiveSpeakerChanged(RtkRemoteParticipant? participant) {
    VideoCallLogger.debug('Active speaker: ${participant?.name ?? "none"}');
  }

  @override
  void onNewBroadcastMessage(String message, Map<String, dynamic> data) {
    VideoCallLogger.debug('Broadcast message: $message');
  }

  @override
  void onScreenShareUpdate(RtkRemoteParticipant participant, bool screenShareEnabled) {
    VideoCallLogger.debug('Screen share: ${participant.name} = $screenShareEnabled');
  }

  @override
  void onUpdate(RtkParticipants participants) {
    VideoCallLogger.debug('Participants updated: ${participants.active.length} active');
    // Force UI update
    _connectionStateController.add(_connectionState);
  }

  @override
  void onParticipantPinned(RtkMeetingParticipant participant) {
    VideoCallLogger.debug('Participant pinned: ${participant.name}');
  }

  @override
  void onParticipantUnpinned(RtkMeetingParticipant participant) {
    VideoCallLogger.debug('Participant unpinned: ${participant.name}');
  }

  // ============================================================================
  // Meeting control methods
  // ============================================================================

  /// Join the meeting room
  /// 
  /// This is called automatically by onMeetingInitCompleted callback
  /// Per SDK documentation, joinRoom() should only be called after init completes
  Future<void> joinMeeting() async {
    if (_client == null) {
      throw VideoCallError.runtime(
        'Client not initialized',
        details: 'Call initializeMeeting() first',
      );
    }

    try {
      VideoCallLogger.logMeetingJoin('meeting');
      
      // Join the room - callbacks will handle state updates
      _client!.joinRoom(
        onSuccess: () {
          VideoCallLogger.debug('joinRoom() success callback');
        },
        onError: (error) {
          VideoCallLogger.error('joinRoom() error callback', error);
          _updateConnectionState(app.ConnectionState.failed);
        },
      );
    } catch (e, stackTrace) {
      VideoCallLogger.error('Failed to join meeting', e, stackTrace);
      _updateConnectionState(app.ConnectionState.failed);
      throw VideoCallError.connection(
        'Failed to join meeting',
        details: e.toString(),
      );
    }
  }

  /// Leave the meeting
  /// 
  /// This properly closes the session on Cloudflare servers
  Future<void> leaveMeeting() async {
    if (_client == null) {
      VideoCallLogger.warning('leaveMeeting() called but client is null');
      return;
    }

    try {
      VideoCallLogger.logMeetingLeave('meeting');
      _isLeaving = true;
      
      // Leave the room - callbacks will handle state updates
      _client!.leaveRoom(
        onSuccess: () {
          VideoCallLogger.debug('leaveRoom() success callback');
        },
        onError: (error) {
          VideoCallLogger.warning('leaveRoom() error callback', error);
        },
      );
    } catch (e, stackTrace) {
      VideoCallLogger.error('Failed to leave meeting', e, stackTrace);
      throw VideoCallError.runtime(
        'Failed to leave meeting',
        details: e.toString(),
      );
    }
  }

  /// Toggle audio (mute/unmute microphone)
  Future<void> toggleAudio() async {
    if (_client == null) {
      throw VideoCallError.runtime('Client not initialized');
    }

    try {
      if (_isAudioEnabled) {
        _client!.localUser.disableAudio();
        _isAudioEnabled = false;
      } else {
        _client!.localUser.enableAudio();
        _isAudioEnabled = true;
      }
      VideoCallLogger.logMediaControl('audio', _isAudioEnabled);
    } catch (e, stackTrace) {
      VideoCallLogger.error('Failed to toggle audio', e, stackTrace);
      throw VideoCallError.runtime(
        'Failed to toggle audio',
        details: e.toString(),
      );
    }
  }

  /// Toggle video (enable/disable camera)
  Future<void> toggleVideo() async {
    if (_client == null) {
      throw VideoCallError.runtime('Client not initialized');
    }

    try {
      if (_isVideoEnabled) {
        _client!.localUser.disableVideo();
        _isVideoEnabled = false;
      } else {
        _client!.localUser.enableVideo();
        _isVideoEnabled = true;
      }
      VideoCallLogger.logMediaControl('video', _isVideoEnabled);
    } catch (e, stackTrace) {
      VideoCallLogger.error('Failed to toggle video', e, stackTrace);
      throw VideoCallError.runtime(
        'Failed to toggle video',
        details: e.toString(),
      );
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_client == null) {
      throw VideoCallError.runtime('Client not initialized');
    }

    try {
      _client!.localUser.switchCamera();
      VideoCallLogger.info('Camera switched');
    } catch (e, stackTrace) {
      VideoCallLogger.error('Failed to switch camera', e, stackTrace);
      throw VideoCallError.runtime(
        'Failed to switch camera',
        details: e.toString(),
      );
    }
  }

  // ============================================================================
  // Resource cleanup
  // ============================================================================

  /// Wait for disconnection with timeout
  /// 
  /// This ensures we properly wait for the leave operation to complete
  /// before disposing resources
  Future<void> _waitForDisconnection({Duration timeout = const Duration(seconds: 5)}) async {
    if (_connectionState == app.ConnectionState.disconnected) {
      VideoCallLogger.debug('Already disconnected');
      return;
    }
    
    VideoCallLogger.debug('Waiting for disconnection...');
    final completer = Completer<void>();
    Timer? timeoutTimer;
    StreamSubscription<app.ConnectionState>? subscription;
    
    subscription = connectionStateStream.listen((state) {
      if (state == app.ConnectionState.disconnected) {
        VideoCallLogger.debug('Disconnection detected');
        timeoutTimer?.cancel();
        subscription?.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    timeoutTimer = Timer(timeout, () {
      VideoCallLogger.warning('Disconnect timeout - forcing completion');
      subscription?.cancel();
      if (!completer.isCompleted) {
        completer.complete();
      }
    });
    
    await completer.future;
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(app.ConnectionState newState) {
    if (_connectionState != newState) {
      _connectionState = newState;
      VideoCallLogger.logConnectionState(newState.toString());
      _connectionStateController.add(newState);
    }
  }

  /// Dispose and cleanup all resources
  /// 
  /// This is CRITICAL for fixing the Cloudflare dashboard issue.
  /// Complete disposal ensures:
  /// 1. Session is properly closed on Cloudflare servers
  /// 2. Native SDK state is cleared (cleanAllNativeListeners)
  /// 3. Client reference is nullified (prevents cached connections)
  /// 4. All state is reset for next call
  Future<void> dispose() async {
    if (_isDisposed || _isLeaving) {
      VideoCallLogger.warning('Dispose called but already disposing/disposed');
      return;
    }
    
    _isDisposed = true;
    VideoCallLogger.info('=== Starting Complete Client Disposal ===');
    
    try {
      // Step 1: Leave meeting if connected
      if (_client != null && _connectionState == app.ConnectionState.connected) {
        VideoCallLogger.info('Leaving meeting before disposal');
        _isLeaving = true;
        
        await leaveMeeting();
        
        // Wait for leave to complete (with timeout)
        await _waitForDisconnection(timeout: const Duration(seconds: 5));
        
        _isLeaving = false;
        VideoCallLogger.info('Leave completed');
      }
      
      // Step 2: Remove all event listeners
      if (_client != null) {
        VideoCallLogger.logCleanup('event listeners');
        _client!.removeMeetingRoomEventListener(this);
        _client!.removeParticipantsEventListener(this);
      }
      
      // Step 3: Clean native listeners
      // This is CRITICAL - it clears native SDK state that prevents new connections
      if (_client != null) {
        VideoCallLogger.logCleanup('native listeners');
        _client!.cleanAllNativeListeners();
      }
      
      // Step 4: Close stream controllers (but don't dispose them permanently)
      VideoCallLogger.logCleanup('stream controllers');
      if (!_connectionStateController.isClosed) {
        await _connectionStateController.close();
      }
      if (!_participantEventController.isClosed) {
        await _participantEventController.close();
      }
      
      // Step 5: Nullify client reference
      // This is CRITICAL - prevents cached state from blocking new connections
      VideoCallLogger.logCleanup('client reference');
      _client = null;
      
      // Step 6: Reset all state
      _connectionState = app.ConnectionState.disconnected;
      _isAudioEnabled = true;
      _isVideoEnabled = true;
      
      VideoCallLogger.info('✅ Complete disposal finished - ready for new connection');
      
    } catch (e, stackTrace) {
      VideoCallLogger.error('Error during disposal', e, stackTrace);
      // Force cleanup even on error
      _client = null;
      _isLeaving = false;
    } finally {
      // Reset disposed flag so service can be reused
      _isDisposed = false;
    }
  }
}
