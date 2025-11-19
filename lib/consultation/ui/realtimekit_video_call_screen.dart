import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:realtimekit_core/realtimekit_core.dart';
import '../controller/realtimekit_video_call_controller.dart';
import '../entities/video_call_config.dart';
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
  late RealtimeKitVideoCallController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(RealtimeKitVideoCallController());
    controller.initialize(widget.config);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        if (controller.isConnected.value) {
          _showEndCallConfirmation();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
        child: Obx(() {
          if (controller.isLoading.value) {
            return _buildLoadingState();
          }

          if (controller.error.value != null) {
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
              controller.error.value ?? 'Unable to connect to the consultation',
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
                    controller.clearError();
                    controller.initialize(widget.config);
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
  }
  
  Widget _buildRemoteVideo() {
    final service = controller.service;
    final participants = service?.participants;
    
    // Check if we have remote participants with video
    if (service != null && 
        participants != null && 
        participants.active.isNotEmpty) {
      final remoteParticipant = participants.active.first;
      
      // Debug log
      print('RealtimeKit: Remote participant: ${remoteParticipant.name}, ID: ${remoteParticipant.id}, Video: ${remoteParticipant.videoEnabled}');
      
      // Show actual remote video using VideoView
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: VideoView(
          key: ValueKey('remote_${remoteParticipant.id}'),
          meetingParticipant: remoteParticipant,
          isSelfParticipant: false,
        ),
      );
    }
    
    // Show placeholder when no remote video
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
              backgroundImage: NetworkImage(controller.doctorImageUrl),
            ),
            const SizedBox(height: 16),
            Text(
              controller.doctorName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              controller.specialization,
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
      final isVideoEnabled = controller.isVideoEnabled.value;
      
      // Debug log
      print('RealtimeKit: Local video enabled: $isVideoEnabled');
      
      if (!isVideoEnabled) {
        // Show placeholder when video is disabled
        return Container(
          width: 120,
          height: 160,
          decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Center(
            child: Icon(
              Icons.videocam_off,
              color: Colors.white,
              size: 40,
            ),
          ),
        );
      }
      
      // Show actual local video using VideoView
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.doctorName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  controller.specialization,
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
            if (controller.isConnected.value) {
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
              controller.isAudioEnabled.value ? Icons.mic : Icons.mic_off,
              color: Colors.white,
              size: 28,
            )),
            onTap: controller.toggleAudio,
            isActive: controller.isAudioEnabled,
          ),
          
          // Camera toggle
          _buildControlButton(
            icon: Obx(() => Icon(
              controller.isVideoEnabled.value ? Icons.videocam : Icons.videocam_off,
              color: Colors.white,
              size: 28,
            )),
            onTap: controller.toggleVideo,
            isActive: controller.isVideoEnabled,
          ),
          
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
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              controller.endCall();
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
