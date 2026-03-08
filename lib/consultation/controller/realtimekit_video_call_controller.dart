import 'package:get/get.dart';
import '../service/realtimekit_service.dart';
import '../entities/connection_state.dart' as app;
import '../entities/video_call_config.dart';
import '../utils/video_call_logger.dart';

class RealtimeKitVideoCallController extends GetxController {
  // Observable states
  final isLoading = true.obs;
  final isConnected = false.obs;
  final isAudioEnabled = true.obs;
  final isVideoEnabled = true.obs;
  final error = Rxn<String>();
  final connectionState = Rx<app.ConnectionState>(app.ConnectionState.disconnected);
  final isMinimized = false.obs; // Track if call is minimized

  // Doctor information
  late String doctorName;
  late String specialization;
  late String doctorImageUrl;

  // Meeting credentials
  late String authToken;
  late String roomName;
  late String participantId;
  String? consultationId;

  // Service instance
  RealtimeKitService? _service;

  // Expose service for video views
  RealtimeKitService? get service => _service;

  RealtimeKitVideoCallController();

  /// Initialize with video call config
  Future<void> initialize(VideoCallConfig config) async {
    try {
      VideoCallLogger.info('Controller: Starting initialization');
      isLoading.value = true;
      error.value = null;

      // Validate config
      VideoCallLogger.debug('Controller: Validating config');
      final validationError = config.getValidationError();
      if (validationError != null) {
        VideoCallLogger.error('Controller: Config validation failed', validationError);
        throw Exception(validationError);
      }
      VideoCallLogger.debug('Controller: Config validated');

      // Store config data
      authToken = config.authToken;
      roomName = config.roomName;
      participantId = config.participantId;
      doctorName = config.doctorName;
      specialization = config.specialization;
      doctorImageUrl = config.doctorImageUrl;
      consultationId = config.consultationId;
      VideoCallLogger.debug('Controller: Config data stored');

      // Initialize service
      VideoCallLogger.debug('Controller: Creating RealtimeKitService');
      _service = RealtimeKitService();

      // Initialize meeting FIRST (this ensures stream controllers are ready)
      VideoCallLogger.info('Controller: Calling service.initializeMeeting()');
      await _service!.initializeMeeting(
        authToken: authToken,
        roomName: roomName,
        participantId: participantId,
      );
      VideoCallLogger.info('Controller: Service initialization complete');

      // Set up connection state listener AFTER initialization
      // This ensures we're listening to the correct (possibly recreated) streams
      VideoCallLogger.debug('Controller: Setting up connection state listener');
      _setupConnectionStateListener();

      // Loading state will be updated by connection state listener

    } catch (e, stackTrace) {
      VideoCallLogger.error('Controller: Initialization failed', e, stackTrace);
      isLoading.value = false;
      handleError('Failed to join consultation: ${e.toString()}');
    }
  }

  /// Toggle audio (mute/unmute)
  Future<void> toggleAudio() async {
    if (_service == null) return;
    try {
      await _service!.toggleAudio();
      isAudioEnabled.value = _service!.isAudioEnabled;
    } catch (e) {
      handleError('Failed to toggle audio: ${e.toString()}');
    }
  }

  /// Toggle video (enable/disable camera)
  Future<void> toggleVideo() async {
    if (_service == null) return;
    try {
      await _service!.toggleVideo();
      isVideoEnabled.value = _service!.isVideoEnabled;
    } catch (e) {
      handleError('Failed to toggle video: ${e.toString()}');
    }
  }

  /// Switch camera (front/back)
  Future<void> switchCamera() async {
    if (_service == null) return;
    try {
      await _service!.switchCamera();
    } catch (e) {
      handleError('Failed to switch camera: ${e.toString()}');
    }
  }

  /// End the call and navigate back
  Future<void> endCall() async {
    if (_service == null) {
      Get.back();
      return;
    }
    try {
      await _service!.leaveMeeting();
      isConnected.value = false;
      Get.back();
    } catch (e) {
      handleError('Failed to end call: ${e.toString()}');
      // Still navigate back even if there's an error
      Get.back();
    }
  }

  /// Handle errors and update error state
  void handleError(String errorMessage) {
    error.value = errorMessage;
    VideoCallLogger.error('Controller error: $errorMessage');
  }

  /// Clear error
  void clearError() {
    error.value = null;
  }

  /// Set up connection state listener after service is initialized
  void _setupConnectionStateListener() {
    final service = _service;
    if (service == null) return;

    service.connectionStateStream.listen((state) {
      connectionState.value = state;
      
      // Update loading and connected states based on connection state
      if (state == app.ConnectionState.connected) {
        isConnected.value = true;
        isLoading.value = false;
        VideoCallLogger.info('Controller: Connected to meeting');
      } else if (state == app.ConnectionState.connecting) {
        isLoading.value = true;
        VideoCallLogger.debug('Controller: Connecting...');
      } else if (state == app.ConnectionState.disconnected || state == app.ConnectionState.failed) {
        isConnected.value = false;
        isLoading.value = false;
        if (state == app.ConnectionState.failed) {
          VideoCallLogger.warning('Controller: Connection failed');
        }
      }
    });

    // Listen for participant events to trigger UI updates
    service.participantEventStream.listen((event) {
      VideoCallLogger.logParticipantEvent(event.type.toString(), event.participantId);
      // Force UI update
      connectionState.refresh();
    });
  }

  @override
  void onClose() {
    VideoCallLogger.debug('Controller: onClose() called');
    VideoCallLogger.debug('Controller: isMinimized = ${isMinimized.value}');
    
    // Only dispose service if call is not minimized
    if (!isMinimized.value) {
      if (_service != null) {
        VideoCallLogger.info('Controller: Disposing service');
        _service!.dispose();
      } else {
        VideoCallLogger.debug('Controller: Service is null, nothing to dispose');
      }
    } else {
      VideoCallLogger.debug('Controller: Call is minimized, skipping disposal');
    }
    
    VideoCallLogger.debug('Controller: onClose() complete');
    super.onClose();
  }
}
