import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtimekit_core/realtimekit_core.dart';
import '../controller/realtimekit_video_call_controller.dart';
import '../controller/minimized_call_manager.dart';
import '../entities/video_call_config.dart';
import '../utils/video_call_logger.dart';
import '../../_shared/ui/app_colors.dart';

class RealtimeKitVideoCallScreen extends StatefulWidget {
  final VideoCallConfig config;

  const RealtimeKitVideoCallScreen({
    super.key,
    required this.config,
  });

  @override
  State<RealtimeKitVideoCallScreen> createState() => _RealtimeKitVideoCallScreenState();
}

class _RealtimeKitVideoCallScreenState extends State<RealtimeKitVideoCallScreen> {
  RealtimeKitVideoCallController? controller;
  bool _isInitializing = true;

  @override
  void initState() {
    super.initState();
    _initializeController();
  }

  Future<void> _initializeController() async {
    setState(() {
      _isInitializing = true;
    });

    try {
      // Check if controller already exists (from minimized state)
      if (Get.isRegistered<RealtimeKitVideoCallController>()) {
        final existingController = Get.find<RealtimeKitVideoCallController>();

        // If controller exists but is NOT minimized, it's a stale controller from previous call
        if (!existingController.isMinimized.value) {
          // Dispose service FIRST before deleting controller
          if (existingController.service != null) {
            await existingController.service!.dispose();
          }
          
          // Wait for disposal to complete
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Delete controller
          Get.delete<RealtimeKitVideoCallController>(force: true);

          // Create new controller
          controller = Get.put(RealtimeKitVideoCallController(), permanent: true);
          await controller!.initialize(widget.config);
        } else {
          // Controller is minimized, reuse it
          controller = existingController;
        }
      } else {
        // Create new controller
        controller = Get.put(RealtimeKitVideoCallController(), permanent: true);
        await controller!.initialize(widget.config);
      }
    } catch (e) {
      VideoCallLogger.error('Screen: Failed to initialize controller', e);
    } finally {
      if (mounted) {
        setState(() {
          _isInitializing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading while controller is initializing
    if (_isInitializing || controller == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(widget.config.doctorImageUrl),
                ),
                const SizedBox(height: 24),
                Text(
                  'Connecting to ${widget.config.doctorName}...',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (controller!.isConnected.value) {
          // Minimize the call instead of showing end call dialog
          final minimizedCallManager = Get.put(MinimizedCallManager(), permanent: true);
          await minimizedCallManager.minimizeCall(context, controller!);
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: Obx(() {
            if (controller!.isLoading.value) {
              return _buildLoadingState();
            }

            if (controller!.error.value != null) {
              return _buildErrorState();
            }

            return _buildVideoCallUI();
          }),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 60,
            backgroundImage: NetworkImage(widget.config.doctorImageUrl),
          ),
          const SizedBox(height: 24),
          Text(
            'Connecting to ${widget.config.doctorName}...',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.config.specialization,
            style: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 32),
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 80,
            ),
            const SizedBox(height: 24),
            const Text(
              'Connection Failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              controller!.error.value ?? 'Unable to connect to the consultation',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    controller!.clearError();
                    controller!.initialize(widget.config);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Retry',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 16),
                OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Go Back',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoCallUI() {
    return Obx(() {
      // Force rebuild when connection state changes (which includes participant events)
      final _ = controller!.connectionState.value;

      return Stack(
        children: [
          // Remote video (doctor) - Full screen
          _buildRemoteVideo(),

          // Local video (patient) - PiP overlay
          Positioned(
            top: 20,
            right: 20,
            child: _buildLocalVideo(),
          ),

          // Top bar with doctor info
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildTopBar(),
          ),

          // Bottom control bar
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildControlBar(),
          ),
        ],
      );
    });
  }

  Widget _buildRemoteVideo() {
    final service = controller!.service;
    final participants = service?.participants;
    final isConnected = controller!.isConnected.value;

    // Debug logs
    print('RealtimeKit: Building remote video - connected: $isConnected, service: ${service != null}, participants: ${participants != null}');
    if (participants != null) {
      print('RealtimeKit: Active: ${participants.active.length}, Joined: ${participants.joined.length}');
    }

    // Try to get remote participant from either active or joined list
    RtkMeetingParticipant? remoteParticipant;

    if (isConnected && service != null && participants != null) {
      // First try active list
      if (participants.active.isNotEmpty) {
        remoteParticipant = participants.active.first;
        print('RealtimeKit: Using ACTIVE participant: ${remoteParticipant.name}');
      }
      // Then try joined list
      else if (participants.joined.isNotEmpty) {
        remoteParticipant = participants.joined.first;
        print('RealtimeKit: Using JOINED participant: ${remoteParticipant.name}');
      }
    }

    // Show VideoView if we have a remote participant AND video is enabled
    if (remoteParticipant != null && remoteParticipant.videoEnabled) {
      print('RealtimeKit: Showing remote video - ${remoteParticipant.name}, ID: ${remoteParticipant.id}, Video: ${remoteParticipant.videoEnabled}');

      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: VideoView(
          key: ValueKey('remote_${remoteParticipant.id}_${remoteParticipant.videoEnabled}'),
          meetingParticipant: remoteParticipant,
          isSelfParticipant: false,
        ),
      );
    }

    // Show placeholder when not connected or no remote participants
    print('RealtimeKit: Showing placeholder - connected: $isConnected, active: ${participants?.active.length ?? 0}, joined: ${participants?.joined.length ?? 0}');
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: NetworkImage(controller!.doctorImageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              controller!.doctorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller!.specialization,
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Waiting for video...',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalVideo() {
    return Obx(() {
      // Access observable to trigger rebuild
      final isVideoEnabled = controller!.isVideoEnabled.value;
      final isConnected = controller!.isConnected.value;

      // Debug log
      print('RealtimeKit: Local video enabled: $isVideoEnabled, connected: $isConnected');

      if (!isVideoEnabled || !isConnected) {
        // Show placeholder when video is disabled or not connected yet
        return Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: Center(
            child: Icon(
              isVideoEnabled ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      }

      // Show actual local video using VideoView ONLY after connected
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.black,
            border: Border.all(color: Colors.white, width: 2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const VideoView(
            key: ValueKey('local_self'),
            isSelfParticipant: true,
          ),
        ),
      );
    });
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withValues(alpha: 0.7),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () async {
              if (controller!.isConnected.value) {
                // Minimize the call
                final minimizedCallManager = Get.put(MinimizedCallManager(), permanent: true);
                await minimizedCallManager.minimizeCall(context, controller!);
              } else {
                Navigator.of(context).pop();
              }
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller!.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller!.specialization,
                  style: TextStyle(
                    color: Colors.grey.shade300,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Connection indicator
          Obx(() {
            if (controller!.isConnected.value) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.successGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.circle, color: Colors.white, size: 8),
                    SizedBox(width: 6),
                    Text(
                      'Connected',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            }
            return Container();
          }),
        ],
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [
            Colors.black.withValues(alpha: 0.8),
            Colors.transparent,
          ],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Microphone toggle
          _buildControlButton(
            icon: Obx(() => Icon(
              controller!.isAudioEnabled.value ? Icons.mic : Icons.mic_off,
              color: Colors.white,
              size: 28,
            )),
            onTap: controller!.toggleAudio,
            isActive: controller!.isAudioEnabled,
          ),

          // Camera toggle
          _buildControlButton(
            icon: Obx(() => Icon(
              controller!.isVideoEnabled.value ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
              size: 28,
            )),
            onTap: controller!.toggleVideo,
            isActive: controller!.isVideoEnabled,
          ),

          // Camera switch button
          Obx(() {
            // Only show switch button when video is enabled
            if (controller!.isVideoEnabled.value) {
              return _buildControlButton(
                icon: const Icon(
                  Icons.flip_camera_ios,
                  color: Colors.white,
                  size: 28,
                ),
                onTap: controller!.switchCamera,
                isActive: true.obs, // Always active when visible
              );
            }
            return const SizedBox.shrink();
          }),

          // End call button
          _buildEndCallButton(),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required Widget icon,
    required VoidCallback onTap,
    required RxBool isActive,
  }) {
    return Obx(() {
      return GestureDetector(
        onTap: onTap,
        child: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: isActive.value
                ? Colors.white.withValues(alpha: 0.2)
                : Colors.red.withValues(alpha: 0.3),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Center(child: icon),
        ),
      );
    });
  }

  Widget _buildEndCallButton() {
    return GestureDetector(
      onTap: _showEndCallConfirmation,
      child: Container(
        width: 60,
        height: 60,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Icon(
            Icons.call_end,
            color: Colors.white,
            size: 32,
          ),
        ),
      ),
    );
  }

  void _showEndCallConfirmation() {
    print('🔴 [SCREEN-END] End call button pressed');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'End Call',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Are you sure you want to end the consultation?'),
        actions: [
          TextButton(
            onPressed: () {
              print('🔴 [SCREEN-END] User cancelled end call');
              Navigator.of(ctx).pop();
            },
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              print('🔴 [SCREEN-END] User confirmed end call');
              Navigator.of(ctx).pop();

              print('🔴 [SCREEN-END] ========================================');
              print('🔴 [SCREEN-END] Starting end call cleanup');
              print('🔴 [SCREEN-END] ========================================');
              
              // Unmark as minimized so service can be disposed
              print('🔴 [SCREEN-END] Setting isMinimized to false...');
              controller!.isMinimized.value = false;
              print('✅ [SCREEN-END] isMinimized set to false');
              
              print('🔴 [SCREEN-END] Calling controller!.endCall()...');
              await controller!.endCall();
              print('✅ [SCREEN-END] controller!.endCall() complete');

              // Force delete the controller from GetX to prevent stale controller on next call
              print('🔴 [SCREEN-END] Force deleting controller!...');
              try {
                final deleted = Get.delete<RealtimeKitVideoCallController>(force: true);
                print('✅ [SCREEN-END] Controller deleted: $deleted');
                
                // Verify deletion
                final stillRegistered = Get.isRegistered<RealtimeKitVideoCallController>();
                print('🔴 [SCREEN-END] Still registered after deletion: $stillRegistered');
              } catch (e) {
                print('❌ [SCREEN-END] Error deleting controller: $e');
              }
              
              print('✅ [SCREEN-END] ========================================');
              print('✅ [SCREEN-END] End call cleanup complete');
              print('✅ [SCREEN-END] ========================================');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('End Call'),
          ),
        ],
      ),
    );
  }
}

