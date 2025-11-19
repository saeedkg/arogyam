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
  
  // Doctor information
  late String doctorName;
  late String specialization;
  late String doctorImageUrl;
  
  // Meeting credentials
  late String authToken;
  late String roomName;
  late String participantId;
  
  // Service instance
  RealtimeKitService? _service;
  
  // Expose service for video views
  RealtimeKitService? get service => _service;
  
  RealtimeKitVideoCallController();
  
  /// Initialize with video call config
  Future<void> initialize(VideoCallConfig config) async {
    try {
      isLoading.value = true;
      error.value = null;
      
      // Validate config
      final validationError = config.getValidationError();
      if (validationError != null) {
        throw Exception(validationError);
      }
      
      // Store config data
      authToken = config.authToken;
      roomName = config.roomName;
      participantId = config.participantId;
      doctorName = config.doctorName;
      specialization = config.specialization;
      doctorImageUrl = config.doctorImageUrl;
      
      // Initialize service
      _service = RealtimeKitService();
      
      // Set up connection state listener
      _setupConnectionStateListener();
      
      // Initialize meeting (join will be called automatically in onMeetingInitCompleted callback)
      await _service!.initializeMeeting(
        authToken: authToken,
        roomName: roomName,
        participantId: participantId,
      );
      
      // Don't call joinMeeting here - it will be called in the onMeetingInitCompleted callback
      // The loading state will be updated when we receive onMeetingRoomJoinCompleted
      
      isLoading.value = false;
      
    } catch (e) {
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
  }
  
  @override
  void onClose() {
    // Dispose service and cleanup resources
    if (_service != null) {
      _service!.dispose();
    }
    super.onClose();
  }
}
