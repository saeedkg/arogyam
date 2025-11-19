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
  late RealtimeKitService _service;
  
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
      
      // Initialize meeting
      await _service.initializeMeeting(
        authToken: authToken,
        roomName: roomName,
        participantId: participantId,
      );
      
      // Join meeting
      await _service.joinMeeting();
      
      // Update states
      isConnected.value = true;
      isLoading.value = false;
      
    } catch (e) {
      isLoading.value = false;
      handleError('Failed to join consultation: ${e.toString()}');
    }
  }
  
  /// Toggle audio (mute/unmute)
  Future<void> toggleAudio() async {
    try {
      await _service.toggleAudio();
      isAudioEnabled.value = _service.isAudioEnabled;
    } catch (e) {
      handleError('Failed to toggle audio: ${e.toString()}');
    }
  }
  
  /// Toggle video (enable/disable camera)
  Future<void> toggleVideo() async {
    try {
      await _service.toggleVideo();
      isVideoEnabled.value = _service.isVideoEnabled;
    } catch (e) {
      handleError('Failed to toggle video: ${e.toString()}');
    }
  }
  
  /// End the call and navigate back
  Future<void> endCall() async {
    try {
      await _service.leaveMeeting();
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
  
  @override
  void onInit() {
    super.onInit();
    // Set up connection state listener
    _service.connectionStateStream.listen((state) {
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
    _service.dispose();
    super.onClose();
  }
}
