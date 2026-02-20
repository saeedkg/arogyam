import 'package:get/get.dart';
import '../service/realtimekit_service.dart';
import '../entities/connection_state.dart' as app;
import '../entities/video_call_config.dart';

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
      print('🔴 [CONTROLLER-INIT] Starting controller initialization...');
      isLoading.value = true;
      error.value = null;

      // Validate config
      print('🔴 [CONTROLLER-INIT] Validating config...');
      final validationError = config.getValidationError();
      if (validationError != null) {
        print('❌ [CONTROLLER-INIT] Config validation failed: $validationError');
        throw Exception(validationError);
      }
      print('✅ [CONTROLLER-INIT] Config validated');

      // Store config data
      authToken = config.authToken;
      roomName = config.roomName;
      participantId = config.participantId;
      doctorName = config.doctorName;
      specialization = config.specialization;
      doctorImageUrl = config.doctorImageUrl;
      consultationId = config.consultationId;
      print('✅ [CONTROLLER-INIT] Config data stored');

      // Initialize service
      print('🔴 [CONTROLLER-INIT] Creating new RealtimeKitService...');
      _service = RealtimeKitService();
      print('✅ [CONTROLLER-INIT] Service created');

      // Set up connection state listener
      print('🔴 [CONTROLLER-INIT] Setting up connection state listener...');
      _setupConnectionStateListener();
      print('✅ [CONTROLLER-INIT] Listener setup complete');

      // Initialize meeting (join will be called automatically in onMeetingInitCompleted callback)
      print('🔴 [CONTROLLER-INIT] Calling service.initializeMeeting()...');
      await _service!.initializeMeeting(
        authToken: authToken,
        roomName: roomName,
        participantId: participantId,
      );
      print('✅ [CONTROLLER-INIT] Service initialization called, waiting for SDK callbacks...');

      // Don't call joinMeeting here - it will be called in the onMeetingInitCompleted callback
      // The loading state will be updated when we receive onMeetingRoomJoinCompleted

      isLoading.value = false;
      print('✅ [CONTROLLER-INIT] Controller initialization complete');

    } catch (e) {
      print('❌ [CONTROLLER-INIT] FAILED: $e');
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
    // Log error for debugging
    print('VideoCallController Error: $errorMessage');
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
      if (state == app.ConnectionState.connected) {
        isConnected.value = true;
      } else if (state == app.ConnectionState.disconnected || state == app.ConnectionState.failed) {
        isConnected.value = false;
      }
    });

    // Listen for participant events to trigger UI updates
    service.participantEventStream.listen((event) {
      print('VideoCallController: Participant event - ${event.type} for ${event.participantId}');
      // Force UI update by updating a dummy observable
      connectionState.refresh();
    });
  }

  @override
  void onClose() {
    print('🔴 [CONTROLLER-CLOSE] onClose() called');
    print('🔴 [CONTROLLER-CLOSE] isMinimized: ${isMinimized.value}');
    
    // Only dispose service if call is not minimized
    if (!isMinimized.value) {
      if (_service != null) {
        print('🔴 [CONTROLLER-CLOSE] Disposing service...');
        _service!.dispose();
        print('✅ [CONTROLLER-CLOSE] Service disposed');
      } else {
        print('⚠️ [CONTROLLER-CLOSE] Service is null, nothing to dispose');
      }
    } else {
      print('⚠️ [CONTROLLER-CLOSE] Call is minimized, skipping disposal');
    }
    
    print('✅ [CONTROLLER-CLOSE] onClose() complete');
    super.onClose();
  }
}
