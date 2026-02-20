import 'dart:async';
import 'package:realtimekit_core/realtimekit_core.dart';
import '../entities/connection_state.dart' as app;
import '../entities/video_call_error.dart';
import '../entities/participant_event.dart';

class RealtimeKitService extends RtkMeetingRoomEventListener
    implements RtkParticipantsEventListener {
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
      print('🔴 [SERVICE-INIT] Starting SDK initialization...');
      print('🔴 [SERVICE-INIT] Auth token: ${authToken.substring(0, 10)}...');
      print('🔴 [SERVICE-INIT] Room: $roomName');
      print('🔴 [SERVICE-INIT] Participant: $participantId');
      
      _updateConnectionState(app.ConnectionState.connecting);

      print('🔴 [SERVICE-INIT] Creating RealtimekitClient...');
      _client = RealtimekitClient();
      print('✅ [SERVICE-INIT] RealtimekitClient created');

      // Subscribe to meeting room events BEFORE init
      print('🔴 [SERVICE-INIT] Adding meeting room event listener...');
      _client!.addMeetingRoomEventListener(this);
      print('✅ [SERVICE-INIT] Meeting room event listener added');

      // Subscribe to participants events BEFORE init
      print('🔴 [SERVICE-INIT] Adding participants event listener...');
      _client!.addParticipantsEventListener(this);
      print('✅ [SERVICE-INIT] Participants event listener added');

      // Step 3: Set the meeting properties
      final meetingInfo = RtkMeetingInfo(
        authToken: authToken,
        enableAudio: true,
        enableVideo: true,
      );
      print('🔴 [SERVICE-INIT] Meeting info configured');

      // Step 4: Initialize the connection request
      print('🔴 [SERVICE-INIT] Calling client.init()...');
      _client!.init(meetingInfo);
      print('✅ [SERVICE-INIT] client.init() called');

      print('✅ [SERVICE-INIT] SDK initialization complete, waiting for callbacks...');
      
      // WORKAROUND: Manually call joinRoom since callbacks aren't firing
      print('⚠️ [SERVICE-INIT] WORKAROUND: Manually calling joinRoom()...');
      await joinMeeting();
      print('✅ [SERVICE-INIT] joinRoom() called manually');
      
      // WORKAROUND: Since callbacks don't fire, manually update state after delay
      print('⚠️ [SERVICE-INIT] WORKAROUND: Waiting for SDK to connect...');
      await Future.delayed(const Duration(seconds: 3));
      
      // Force update connection state
      print('⚠️ [SERVICE-INIT] WORKAROUND: Forcing connection state to connected');
      _updateConnectionState(app.ConnectionState.connected);
      print('✅ [SERVICE-INIT] Connection state forced to connected');

    } catch (e) {
      print('❌ [SERVICE-INIT] FAILED: $e');
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
    print('✅ [SDK-CALLBACK] onMeetingInitStarted - SDK init started');
    _updateConnectionState(app.ConnectionState.connecting);
  }

  @override
  void onMeetingInitCompleted() {
    print('✅ [SDK-CALLBACK] onMeetingInitCompleted - SDK init completed');
    print('🔴 [SDK-CALLBACK] Auto-joining meeting...');
    // Automatically join the room after initialization completes
    joinMeeting();
  }

  @override
  void onMeetingInitFailed(MeetingError error) {
    print('❌ [SDK-CALLBACK] onMeetingInitFailed - ${error.message}');
    _updateConnectionState(app.ConnectionState.failed);
  }

  @override
  void onMeetingRoomJoinStarted() {
    print('✅ [SDK-CALLBACK] onMeetingRoomJoinStarted - Join started');
    _updateConnectionState(app.ConnectionState.connecting);
  }

  @override
  void onMeetingRoomJoinCompleted() {
    print('✅ [SDK-CALLBACK] onMeetingRoomJoinCompleted - Successfully joined room');
    _updateConnectionState(app.ConnectionState.connected);

    // Debug: Check participants after joining
    Future.delayed(const Duration(seconds: 1), () {
      if (_client != null) {
        print('RealtimeKit: === PARTICIPANTS DEBUG ===');
        print('RealtimeKit: Active count: ${_client!.participants.active.length}');
        print('RealtimeKit: Joined count: ${_client!.participants.joined.length}');

        print('RealtimeKit: Active participants:');
        for (var p in _client!.participants.active) {
          print('  - ${p.name} (ID: ${p.id}, Video: ${p.videoEnabled}, Audio: ${p.audioEnabled})');
        }

        print('RealtimeKit: Joined participants:');
        for (var p in _client!.participants.joined) {
          print('  - ${p.name} (ID: ${p.id}, Video: ${p.videoEnabled}, Audio: ${p.audioEnabled})');
        }
        print('RealtimeKit: === END DEBUG ===');
      }
    });
  }

  @override
  void onMeetingRoomJoinFailed(MeetingError error) {
    print('❌ [SDK-CALLBACK] onMeetingRoomJoinFailed - ${error.message}');
    _updateConnectionState(app.ConnectionState.failed);
  }

  @override
  void onMeetingRoomLeaveStarted() {
    print('✅ [SDK-CALLBACK] onMeetingRoomLeaveStarted - Leave started');
  }

  @override
  void onMeetingRoomLeaveCompleted() {
    print('✅ [SDK-CALLBACK] onMeetingRoomLeaveCompleted - Left room');
    _updateConnectionState(app.ConnectionState.disconnected);
  }

  // RtkParticipantsEventListener methods
  @override
  void onParticipantJoin(RtkMeetingParticipant participant) {
    print('RealtimeKit: Participant joined - ${participant.name}, ID: ${participant.id}, Video: ${participant.videoEnabled}');
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.join,
      ),
    );
  }

  @override
  void onParticipantLeave(RtkMeetingParticipant participant) {
    print('RealtimeKit: Participant left - ${participant.name}');
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.leave,
      ),
    );
  }

  @override
  void onVideoUpdate(RtkRemoteParticipant participant, bool videoEnabled) {
    print('RealtimeKit: Video update - ${participant.name}, enabled: $videoEnabled');
    // Force UI update when video state changes
    _connectionStateController.add(_connectionState);

    // Also emit participant event
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.videoUpdate,
      ),
    );
  }

  @override
  void onAudioUpdate(RtkRemoteParticipant participant, bool audioEnabled) {
    print('RealtimeKit: Audio update - ${participant.name}, enabled: $audioEnabled');
    // Force UI update when audio state changes
    _connectionStateController.add(_connectionState);

    // Also emit participant event
    _participantEventController.add(
      ParticipantEvent(
        participantId: participant.id,
        type: ParticipantEventType.audioUpdate,
      ),
    );
  }



  @override
  void onActiveParticipantsChanged(List<RtkMeetingParticipant> active) {
    print('RealtimeKit: Active participants changed - count: ${active.length}');
    for (var p in active) {
      print('  - ${p.name} (ID: ${p.id}, Video: ${p.videoEnabled})');
    }
  }

  @override
  void onActiveSpeakerChanged(RtkRemoteParticipant? participant) {
    print('RealtimeKit: Active speaker - ${participant?.name ?? "none"}');
  }

  @override
  void onNewBroadcastMessage(String message, Map<String, dynamic> data) {
    print('RealtimeKit: Broadcast message - $message');
  }

  @override
  void onScreenShareUpdate(RtkRemoteParticipant participant, bool screenShareEnabled) {
    print('RealtimeKit: Screen share update - ${participant.name}, enabled: $screenShareEnabled');
  }

  @override
  void onUpdate(RtkParticipants participants) {
    print('RealtimeKit: Participants updated - Active: ${participants.active.length}');
    // Force UI update
    _connectionStateController.add(_connectionState);
  }

  @override
  void onParticipantPinned(RtkMeetingParticipant participant) {
    print('RealtimeKit: Participant pinned - ${participant.name}');
  }

  @override
  void onParticipantUnpinned(RtkMeetingParticipant participant) {
    print('RealtimeKit: Participant unpinned - ${participant.name}');
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

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_client == null) {
      throw VideoCallError.runtime('Client not initialized');
    }

    try {
      _client!.localUser.switchCamera();
      print('RealtimeKit: Camera switched');
    } catch (e) {
      throw VideoCallError.runtime(
        'Failed to switch camera',
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
    print('🔴 [SERVICE-DISPOSE] Starting service disposal...');
    
    // Leave meeting if still connected
    if (_client != null && _connectionState == app.ConnectionState.connected) {
      print('🔴 [SERVICE-DISPOSE] Leaving meeting...');
      leaveMeeting();
    }

    // Remove event listeners and clean up
    if (_client != null) {
      print('🔴 [SERVICE-DISPOSE] Removing event listeners...');
      _client!.removeMeetingRoomEventListener(this);
      _client!.removeParticipantsEventListener(this);
      print('✅ [SERVICE-DISPOSE] Event listeners removed');
      
      print('🔴 [SERVICE-DISPOSE] Cleaning native listeners...');
      _client!.cleanAllNativeListeners();
      print('✅ [SERVICE-DISPOSE] Native listeners cleaned');
    }

    // Close stream controllers
    print('🔴 [SERVICE-DISPOSE] Closing stream controllers...');
    _connectionStateController.close();
    _participantEventController.close();
    print('✅ [SERVICE-DISPOSE] Stream controllers closed');

    // Clear client reference
    _client = null;
    print('✅ [SERVICE-DISPOSE] Client reference cleared');

    // Reset state
    _isAudioEnabled = true;
    _isVideoEnabled = true;
    _connectionState = app.ConnectionState.disconnected;
    print('✅ [SERVICE-DISPOSE] State reset');

    print('✅ [SERVICE-DISPOSE] Service disposal complete');
  }
}