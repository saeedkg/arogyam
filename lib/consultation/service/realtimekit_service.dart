import 'dart:async';
import 'package:realtimekit_core/realtimekit_core.dart';
import '../entities/connection_state.dart' as app;
import '../entities/video_call_error.dart';

enum ParticipantEventType {
  joined,
  left,
  audioEnabled,
  audioDisabled,
  videoEnabled,
  videoDisabled,
}

class ParticipantEvent {
  final String participantId;
  final ParticipantEventType type;
  final DateTime timestamp;

  ParticipantEvent({
    required this.participantId,
    required this.type,
    required this.timestamp,
  });
}

class RealtimeKitService extends RtkMeetingRoomEventListener {
  RealtimekitClient? _client;

  // State properties
  bool _isAudioEnabled = true;
  bool _isVideoEnabled = true;
  app.ConnectionState _connectionState = app.ConnectionState.disconnected;

  // Stream controllers
  final _connectionStateController = StreamController<app.ConnectionState>.broadcast();
  final _participantEventController = StreamController<ParticipantEvent>.broadcast();

  // Getters
  bool get isAudioEnabled => _isAudioEnabled;
  bool get isVideoEnabled => _isVideoEnabled;
  app.ConnectionState get connectionState => _connectionState;
  Stream<app.ConnectionState> get connectionStateStream => _connectionStateController.stream;
  Stream<ParticipantEvent> get participantEventStream => _participantEventController.stream;
  RealtimekitClient? get client => _client;

  RealtimeKitService();

  /// Initialize meeting with credentials
  Future<void> initializeMeeting({
    required String authToken,
    required String roomName,
    required String participantId,
  }) async {
    try {
      _updateConnectionState(app.ConnectionState.connecting);

      // Step 2: Initialize the SDK
      _client = RealtimekitClient();

      // Step 3: Set the meeting properties
      final meetingInfo = RtkMeetingInfo(
        authToken: authToken,
        enableAudio: true,
        enableVideo: true,
      );

      // Step 4: Initialize the connection request
      _client!.init(meetingInfo);

      // Subscribe to meeting room events
      _client!.addMeetingRoomEventListener(this);

      print('RealtimeKit: Initialized with token: ${authToken.substring(0, 10)}...');

    } catch (e) {
      _updateConnectionState(app.ConnectionState.failed);
      throw VideoCallError.authentication(
        'Failed to initialize meeting',
        details: e.toString(),
      );
    }
  }

  // RtkMeetingRoomEventListener implementations
  @override
  void onMeetingInitStarted() {
    print('RealtimeKit: Meeting init started');
    _updateConnectionState(app.ConnectionState.connecting);
  }

  @override
  void onMeetingInitCompleted() {
    print('RealtimeKit: Meeting init completed');
    // Automatically join the room after initialization completes
    joinMeeting();
  }

  @override
  void onMeetingInitFailed(MeetingError error) {
    print('RealtimeKit: Meeting init failed - ${error.message}');
    _updateConnectionState(app.ConnectionState.failed);
  }

  @override
  void onMeetingRoomJoinStarted() {
    print('RealtimeKit: Join started');
    _updateConnectionState(app.ConnectionState.connecting);
  }

  @override
  void onMeetingRoomJoinCompleted() {
    print('RealtimeKit: Successfully joined room');
    _updateConnectionState(app.ConnectionState.connected);
  }

  @override
  void onMeetingRoomJoinFailed(MeetingError error) {
    print('RealtimeKit: Join failed - ${error.message}');
    _updateConnectionState(app.ConnectionState.failed);
  }

  @override
  void onMeetingRoomLeaveStarted() {
    print('RealtimeKit: Leave started');
  }

  @override
  void onMeetingRoomLeaveCompleted() {
    print('RealtimeKit: Left room');
    _updateConnectionState(app.ConnectionState.disconnected);
  }

  void onParticipantJoined(RtkMeetingParticipant participant) {
    print('RealtimeKit: Participant joined - ${participant.name}, ID: ${participant.id}, Video: ${participant.videoEnabled}');
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.joined,
        timestamp: DateTime.now(),
      ),
    );
  }

  void onParticipantLeft(RtkMeetingParticipant participant) {
    print('RealtimeKit: Participant left - ${participant.name}');
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.left,
        timestamp: DateTime.now(),
      ),
    );
  }

  /// Update connection state and notify listeners
  void _updateConnectionState(app.ConnectionState newState) {
    _connectionState = newState;
    _connectionStateController.add(newState);
  }

  /// Join the meeting room
  Future<void> joinMeeting() async {
    if (_client == null) {
      throw VideoCallError.runtime(
        'Client not initialized',
        details: 'Call initializeMeeting() first',
      );
    }

    try {
      print('RealtimeKit: Attempting to join meeting...');

      // Step 5: Join the room
      _client!.joinRoom(
        onSuccess: () {
          print('RealtimeKit: Join success callback');
        },
        onError: (error) {
          print('RealtimeKit: Join error callback - $error');
          _updateConnectionState(app.ConnectionState.failed);
        },
      );

    } catch (e) {
      print('RealtimeKit: Failed to join - $e');
      _updateConnectionState(app.ConnectionState.failed);
      throw VideoCallError.connection(
        'Failed to join meeting',
        details: e.toString(),
      );
    }
  }

  /// Leave the meeting and cleanup
  Future<void> leaveMeeting() async {
    if (_client == null) return;

    try {
      print('RealtimeKit: Leaving meeting...');

      // Leave the room
      _client!.leaveRoom(
        onSuccess: () {
          print('RealtimeKit: Leave success');
        },
        onError: (error) {
          print('RealtimeKit: Leave error - $error');
        },
      );

    } catch (e) {
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
        print('RealtimeKit: Audio disabled');
      } else {
        _client!.localUser.enableAudio();
        _isAudioEnabled = true;
        print('RealtimeKit: Audio enabled');
      }
    } catch (e) {
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
        print('RealtimeKit: Video disabled');
      } else {
        _client!.localUser.enableVideo();
        _isVideoEnabled = true;
        print('RealtimeKit: Video enabled');
      }
    } catch (e) {
      throw VideoCallError.runtime(
        'Failed to toggle video',
        details: e.toString(),
      );
    }
  }

  /// Get local user for video rendering
  RtkSelfParticipant? get localUser => _client?.localUser;

  /// Get remote participants for video rendering
  RtkParticipants? get participants => _client?.participants;

  /// Dispose and cleanup all resources
  void dispose() {
    // Leave meeting if still connected
    if (_client != null && _connectionState == app.ConnectionState.connected) {
      leaveMeeting();
    }

    // Remove event listener and clean up
    if (_client != null) {
      _client!.removeMeetingRoomEventListener(this);
      _client!.cleanAllNativeListeners();
    }

    // Close stream controllers
    _connectionStateController.close();
    _participantEventController.close();

    // Clear client reference
    _client = null;

    // Reset state
    _isAudioEnabled = true;
    _isVideoEnabled = true;
    _connectionState = app.ConnectionState.disconnected;

    print('RealtimeKit: Service disposed');
  }
}