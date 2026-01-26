// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:realtimekit_core/realtimekit_core.dart';
// import '../entities/corner_position.dart';
// import '../ui/minimized_call_widget.dart';
// import '../../_shared/ui/app_colors.dart';
// import 'realtimekit_video_call_controller.dart';
//
// /// Singleton controller that manages the minimized video call state and overlay lifecycle
// class MinimizedCallManager extends GetxController {
//   // Observable state
//   final isCallMinimized = false.obs;
//   final minimizedPosition = Rx<Offset>(Offset.zero);
//   final callDuration = 0.obs;
//
//   // References
//   OverlayEntry? _overlayEntry;
//   RealtimeKitVideoCallController? _videoCallController;
//   Timer? _durationTimer;
//   StreamSubscription? _connectionStateSubscription;
//   StreamSubscription? _participantEventSubscription;
//
//   // Constants
//   static const double widgetWidth = 120.0;
//   static const double widgetHeight = 160.0;
//   static const double edgePadding = 16.0;
//
//   /// Get the current video call controller
//   RealtimeKitVideoCallController? get videoCallController => _videoCallController;
//
//   /// Check if there's an active minimized call
//   bool get hasActiveCall => _videoCallController != null && isCallMinimized.value;
//
//   /// Minimize the current video call
//   Future<void> minimizeCall(
//     BuildContext context,
//     RealtimeKitVideoCallController controller,
//   ) async {
//     try {
//       // IMPORTANT: Mark controller as minimized FIRST
//       // This prevents the service from being disposed in onClose()
//       controller.isMinimized.value = true;
//
//       // Store reference to controller
//       _videoCallController = controller;
//
//       // Calculate initial position (bottom-right corner)
//       final screenSize = MediaQuery.of(context).size;
//       final widgetSize = const Size(widgetWidth, widgetHeight);
//       final initialPosition = CornerPosition.bottomRight.getOffset(
//         screenSize,
//         widgetSize,
//         edgePadding,
//       );
//
//       minimizedPosition.value = initialPosition;
//       isCallMinimized.value = true;
//
//       // Start duration timer
//       _startDurationTimer();
//
//       // Set up connection state monitoring
//       _setupConnectionStateMonitoring();
//
//       // Apply performance optimizations for minimized state
//       _applyMinimizedPerformanceSettings();
//
//       // Create and insert overlay at root level
//       _overlayEntry = _createOverlayEntry(context);
//
//       // Use the root navigator's overlay to ensure persistence
//       final rootOverlay = Navigator.of(context, rootNavigator: true).overlay;
//       if (rootOverlay != null) {
//         rootOverlay.insert(_overlayEntry!);
//       } else {
//         // Fallback to regular overlay
//         Overlay.of(context).insert(_overlayEntry!);
//       }
//
//       // Pop the video call screen
//       // The controller is marked as minimized, so onClose() won't dispose the service
//       Navigator.of(context).pop();
//
//       print('MinimizedCallManager: Call minimized successfully');
//     } catch (e) {
//       print('MinimizedCallManager: Error minimizing call - $e');
//       // Clean up on error
//       controller.isMinimized.value = false;
//       isCallMinimized.value = false;
//       _videoCallController = null;
//       _stopDurationTimer();
//     }
//   }
//
//   /// Expand the minimized call back to full screen
//   Future<void> expandCall(BuildContext context) async {
//     try {
//       if (_videoCallController == null) return;
//
//       final controller = _videoCallController!;
//
//       // Remove overlay first
//       _removeOverlay();
//
//       // Reset minimized state
//       isCallMinimized.value = false;
//       controller.isMinimized.value = false;
//
//       // Restore full performance settings
//       _restoreFullPerformanceSettings();
//
//       // Stop duration timer
//       _stopDurationTimer();
//
//       // Navigate back to video call screen with existing controller
//       Navigator.of(context).push(
//         MaterialPageRoute(
//           builder: (context) => _ExpandedVideoCallScreen(
//             controller: controller,
//           ),
//         ),
//       );
//
//       print('MinimizedCallManager: Call expanded successfully');
//     } catch (e) {
//       print('MinimizedCallManager: Error expanding call - $e');
//     }
//   }
//
//   /// Update the position of the minimized widget
//   void updatePosition(Offset newPosition) {
//     minimizedPosition.value = newPosition;
//   }
//
//   /// Snap the widget to the nearest corner
//   Offset snapToNearestCorner(Offset position, Size screenSize) {
//     final widgetSize = const Size(widgetWidth, widgetHeight);
//     final nearestCorner = CornerPosition.findNearest(position, screenSize);
//     return nearestCorner.getOffset(screenSize, widgetSize, edgePadding);
//   }
//
//   /// Animate snap to nearest corner
//   Future<void> animateSnapToCorner(Offset currentPosition, Size screenSize) async {
//     final targetPosition = snapToNearestCorner(currentPosition, screenSize);
//
//     // Animate from current to target position over 250ms
//     const duration = Duration(milliseconds: 250);
//     const steps = 15; // 60 FPS approximation
//     final stepDuration = duration.inMilliseconds ~/ steps;
//
//     for (int i = 1; i <= steps; i++) {
//       final t = i / steps;
//       // Use easeInOut curve
//       final curvedT = t < 0.5
//           ? 2 * t * t
//           : -1 + (4 - 2 * t) * t;
//
//       final newPosition = Offset.lerp(currentPosition, targetPosition, curvedT)!;
//       minimizedPosition.value = newPosition;
//
//       await Future.delayed(Duration(milliseconds: stepDuration));
//     }
//
//     // Ensure final position is exact
//     minimizedPosition.value = targetPosition;
//   }
//
//   /// End the call and clean up
//   Future<void> endCall() async {
//     try {
//       // End the video call
//       if (_videoCallController != null) {
//         // Unmark as minimized so it can be disposed
//         _videoCallController!.isMinimized.value = false;
//         await _videoCallController!.endCall();
//
//         // Force delete the controller from GetX
//         try {
//           Get.delete<RealtimeKitVideoCallController>(force: true);
//         } catch (e) {
//           print('MinimizedCallManager: Error deleting controller - $e');
//         }
//       }
//
//       // Clean up
//       _cleanup();
//     } catch (e) {
//       print('MinimizedCallManager: Error ending call - $e');
//       // Clean up anyway
//       _cleanup();
//     }
//   }
//
//   /// Start the duration timer
//   void _startDurationTimer() {
//     _stopDurationTimer(); // Stop any existing timer
//     callDuration.value = 0;
//
//     _durationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       callDuration.value++;
//     });
//   }
//
//   /// Stop the duration timer
//   void _stopDurationTimer() {
//     _durationTimer?.cancel();
//     _durationTimer = null;
//   }
//
//   /// Create the overlay entry
//   OverlayEntry _createOverlayEntry(BuildContext context) {
//     return OverlayEntry(
//       builder: (context) => Obx(() {
//         if (_videoCallController == null) return const SizedBox.shrink();
//
//         return MinimizedCallWidget(
//           controller: _videoCallController!,
//           position: minimizedPosition.value,
//           formattedDuration: _formatDuration(callDuration.value),
//           onTap: () => expandCall(context),
//           onClose: () => _showEndCallConfirmation(context),
//           onDragUpdate: (newPosition) {
//             updatePosition(newPosition);
//           },
//         );
//       }),
//     );
//   }
//
//   /// Show end call confirmation dialog
//   void _showEndCallConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'End Call',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         content: const Text('Are you sure you want to end the consultation?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey.shade700),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               endCall();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('End Call'),
//           ),
//         ],
//       ),
//     );
//   }
//
//   /// Remove the overlay
//   void _removeOverlay() {
//     _overlayEntry?.remove();
//     _overlayEntry?.dispose();
//     _overlayEntry = null;
//   }
//
//   /// Apply performance optimizations for minimized state
//   void _applyMinimizedPerformanceSettings() {
//     // TODO: When RealtimeKit SDK provides APIs for video quality control:
//     // - Reduce remote video resolution to 240p
//     // - Reduce local video frame rate to 15 FPS
//     // - Limit rendering to 30 FPS maximum
//
//     // For now, log that optimizations would be applied
//     print('MinimizedCallManager: Performance optimizations applied for minimized state');
//   }
//
//   /// Restore full performance settings
//   void _restoreFullPerformanceSettings() {
//     // TODO: When RealtimeKit SDK provides APIs for video quality control:
//     // - Restore remote video resolution to original quality
//     // - Restore local video frame rate to 30 FPS
//     // - Remove rendering limitations
//
//     // For now, log that optimizations would be restored
//     print('MinimizedCallManager: Performance settings restored for full screen');
//   }
//
//   /// Clean up all resources
//   void _cleanup() {
//     _removeOverlay();
//     _stopDurationTimer();
//     _stopConnectionStateMonitoring();
//
//     // Unmark controller as minimized
//     if (_videoCallController != null) {
//       _videoCallController!.isMinimized.value = false;
//     }
//
//     _videoCallController = null;
//     isCallMinimized.value = false;
//     callDuration.value = 0;
//     minimizedPosition.value = Offset.zero;
//   }
//
//   /// Set up connection state monitoring
//   void _setupConnectionStateMonitoring() {
//     final service = _videoCallController?.service;
//     if (service == null) return;
//
//     // Listen to connection state changes
//     _connectionStateSubscription = service.connectionStateStream.listen((state) {
//       // Only log state changes, don't auto-cleanup
//       // The user can manually end the call if needed
//       print('MinimizedCallManager: Connection state changed to $state');
//     });
//
//     // Listen to participant events
//     _participantEventSubscription = service.participantEventStream.listen((event) {
//       // Only log participant events, don't auto-cleanup
//       // The minimized call should persist even if doctor hasn't joined yet
//       print('MinimizedCallManager: Participant event - ${event.type}');
//     });
//   }
//
//   /// Stop connection state monitoring
//   void _stopConnectionStateMonitoring() {
//     _connectionStateSubscription?.cancel();
//     _connectionStateSubscription = null;
//     _participantEventSubscription?.cancel();
//     _participantEventSubscription = null;
//   }
//
//   /// Handle connection lost
//   void _handleConnectionLost() {
//     if (!isCallMinimized.value) return;
//
//     // Show reconnection snackbar
//     Get.snackbar(
//       'Connection Lost',
//       'Trying to reconnect...',
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.orange,
//       colorText: Colors.white,
//       duration: const Duration(seconds: 3),
//     );
//
//     // Auto-end call after 10 seconds if still disconnected
//     Future.delayed(const Duration(seconds: 10), () {
//       if (isCallMinimized.value && !(_videoCallController?.isConnected.value ?? false)) {
//         Get.snackbar(
//           'Call Ended',
//           'Connection could not be restored',
//           snackPosition: SnackPosition.TOP,
//           backgroundColor: Colors.red,
//           colorText: Colors.white,
//         );
//         _cleanup();
//       }
//     });
//   }
//
//   /// Handle remote participant left
//   void _handleRemoteParticipantLeft() {
//     if (!isCallMinimized.value) return;
//
//     Get.snackbar(
//       'Call Ended',
//       'The doctor has left the consultation',
//       snackPosition: SnackPosition.TOP,
//       backgroundColor: Colors.grey.shade800,
//       colorText: Colors.white,
//     );
//
//     _cleanup();
//   }
//
//   /// Check if there's an existing call before starting a new one
//   static bool canStartNewCall() {
//     try {
//       final manager = Get.find<MinimizedCallManager>();
//       return !manager.hasActiveCall;
//     } catch (e) {
//       // Manager not initialized, so no active call
//       return true;
//     }
//   }
//
//   /// Show dialog to end existing call before starting new one
//   static Future<bool> showEndExistingCallDialog(BuildContext context) async {
//     final result = await showDialog<bool>(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'Active Call',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         content: const Text(
//           'You have an active call. End current call to start a new one?',
//         ),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(false),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey.shade700),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () => Navigator.of(ctx).pop(true),
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('End Current Call'),
//           ),
//         ],
//       ),
//     );
//
//     if (result == true) {
//       try {
//         final manager = Get.find<MinimizedCallManager>();
//         await manager.endCall();
//         return true;
//       } catch (e) {
//         print('MinimizedCallManager: Error ending existing call - $e');
//         return false;
//       }
//     }
//
//     return false;
//   }
//
//   /// Format duration in MM:SS format
//   String _formatDuration(int seconds) {
//     final minutes = seconds ~/ 60;
//     final secs = seconds % 60;
//     return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
//   }
//
//   @override
//   void onClose() {
//     _cleanup();
//     super.onClose();
//   }
// }
//
//
// /// A simplified video call screen for expanding from minimized state
// class _ExpandedVideoCallScreen extends StatelessWidget {
//   final RealtimeKitVideoCallController controller;
//
//   const _ExpandedVideoCallScreen({required this.controller});
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: false,
//       onPopInvokedWithResult: (didPop, result) async {
//         if (didPop) return;
//
//         if (controller.isConnected.value) {
//           // Minimize again when back is pressed
//           final minimizedCallManager = Get.find<MinimizedCallManager>();
//           await minimizedCallManager.minimizeCall(context, controller);
//         } else {
//           Navigator.of(context).pop();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: SafeArea(
//           child: Obx(() {
//             if (controller.error.value != null) {
//               return _buildErrorState(context);
//             }
//
//             return _buildVideoCallUI(context);
//           }),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildErrorState(BuildContext context) {
//     return Center(
//       child: Padding(
//         padding: const EdgeInsets.all(32),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             const Icon(
//               Icons.error_outline,
//               color: Colors.red,
//               size: 80,
//             ),
//             const SizedBox(height: 24),
//             const Text(
//               'Connection Failed',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               controller.error.value ?? 'Unable to connect to the consultation',
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: Colors.grey.shade400,
//                 fontSize: 16,
//               ),
//             ),
//             const SizedBox(height: 32),
//             ElevatedButton(
//               onPressed: () => Navigator.of(context).pop(),
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: Colors.red,
//                 foregroundColor: Colors.white,
//                 padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               child: const Text(
//                 'End Call',
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVideoCallUI(BuildContext context) {
//     return Obx(() {
//       final _ = controller.connectionState.value;
//
//       return Stack(
//         children: [
//           // Remote video (doctor) - Full screen
//           _buildRemoteVideo(),
//
//           // Local video (patient) - PiP overlay
//           Positioned(
//             top: 20,
//             right: 20,
//             child: _buildLocalVideo(),
//           ),
//
//           // Top bar with doctor info
//           Positioned(
//             top: 0,
//             left: 0,
//             right: 0,
//             child: _buildTopBar(),
//           ),
//
//           // Bottom control bar
//           Positioned(
//             bottom: 0,
//             left: 0,
//             right: 0,
//             child: _buildControlBar(context),
//           ),
//         ],
//       );
//     });
//   }
//
//   Widget _buildRemoteVideo() {
//     final service = controller.service;
//     final participants = service?.participants;
//     final isConnected = controller.isConnected.value;
//
//     RtkMeetingParticipant? remoteParticipant;
//
//     if (isConnected && service != null && participants != null) {
//       if (participants.active.isNotEmpty) {
//         remoteParticipant = participants.active.first;
//       } else if (participants.joined.isNotEmpty) {
//         remoteParticipant = participants.joined.first;
//       }
//     }
//
//     if (remoteParticipant != null && remoteParticipant.videoEnabled) {
//       return Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.black,
//         child: VideoView(
//           key: ValueKey('remote_${remoteParticipant.id}_${remoteParticipant.videoEnabled}'),
//           meetingParticipant: remoteParticipant,
//           isSelfParticipant: false,
//         ),
//       );
//     }
//
//     return Container(
//       width: double.infinity,
//       height: double.infinity,
//       color: Colors.grey.shade900,
//       child: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             CircleAvatar(
//               radius: 60,
//               backgroundImage: NetworkImage(controller.doctorImageUrl),
//             ),
//             const SizedBox(height: 16),
//             Text(
//               controller.doctorName,
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontSize: 24,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               controller.specialization,
//               style: TextStyle(
//                 color: Colors.grey.shade400,
//                 fontSize: 16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildLocalVideo() {
//     return Obx(() {
//       final isVideoEnabled = controller.isVideoEnabled.value;
//       final isConnected = controller.isConnected.value;
//
//       if (!isVideoEnabled || !isConnected) {
//         return Container(
//           width: 120,
//           height: 160,
//           decoration: BoxDecoration(
//             color: Colors.grey.shade800,
//             borderRadius: BorderRadius.circular(12),
//             border: Border.all(color: Colors.white, width: 2),
//           ),
//           child: Center(
//             child: Icon(
//               isVideoEnabled ? Icons.videocam : Icons.videocam_off,
//               color: Colors.white,
//               size: 40,
//             ),
//           ),
//         );
//       }
//
//       return ClipRRect(
//         borderRadius: BorderRadius.circular(12),
//         child: Container(
//           width: 120,
//           height: 160,
//           decoration: BoxDecoration(
//             color: Colors.black,
//             border: Border.all(color: Colors.white, width: 2),
//             borderRadius: BorderRadius.circular(12),
//           ),
//           child: const VideoView(
//             key: ValueKey('local_self'),
//             isSelfParticipant: true,
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildTopBar() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.topCenter,
//           end: Alignment.bottomCenter,
//           colors: [
//             Colors.black.withValues(alpha: 0.7),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   controller.doctorName,
//                   style: const TextStyle(
//                     color: Colors.white,
//                     fontSize: 18,
//                     fontWeight: FontWeight.w700,
//                   ),
//                 ),
//                 const SizedBox(height: 4),
//                 Text(
//                   controller.specialization,
//                   style: TextStyle(
//                     color: Colors.grey.shade300,
//                     fontSize: 14,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           Obx(() {
//             if (controller.isConnected.value) {
//               return Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//                 decoration: BoxDecoration(
//                   color: AppColors.successGreen,
//                   borderRadius: BorderRadius.circular(20),
//                 ),
//                 child: const Row(
//                   children: [
//                     Icon(Icons.circle, color: Colors.white, size: 8),
//                     SizedBox(width: 6),
//                     Text(
//                       'Connected',
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: 12,
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             }
//             return Container();
//           }),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControlBar(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.bottomCenter,
//           end: Alignment.topCenter,
//           colors: [
//             Colors.black.withValues(alpha: 0.8),
//             Colors.transparent,
//           ],
//         ),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//         children: [
//           _buildControlButton(
//             icon: Obx(() => Icon(
//               controller.isAudioEnabled.value ? Icons.mic : Icons.mic_off,
//               color: Colors.white,
//               size: 28,
//             )),
//             onTap: controller.toggleAudio,
//             isActive: controller.isAudioEnabled,
//           ),
//           _buildControlButton(
//             icon: Obx(() => Icon(
//               controller.isVideoEnabled.value ? Icons.videocam : Icons.videocam_off,
//               color: Colors.white,
//               size: 28,
//             )),
//             onTap: controller.toggleVideo,
//             isActive: controller.isVideoEnabled,
//           ),
//           _buildEndCallButton(context),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildControlButton({
//     required Widget icon,
//     required VoidCallback onTap,
//     required RxBool isActive,
//   }) {
//     return Obx(() {
//       return GestureDetector(
//         onTap: onTap,
//         child: Container(
//           width: 60,
//           height: 60,
//           decoration: BoxDecoration(
//             color: isActive.value
//                 ? Colors.white.withValues(alpha: 0.2)
//                 : Colors.red.withValues(alpha: 0.3),
//             shape: BoxShape.circle,
//             border: Border.all(
//               color: Colors.white.withValues(alpha: 0.3),
//               width: 2,
//             ),
//           ),
//           child: Center(child: icon),
//         ),
//       );
//     });
//   }
//
//   Widget _buildEndCallButton(BuildContext context) {
//     return GestureDetector(
//       onTap: () => _showEndCallConfirmation(context),
//       child: Container(
//         width: 60,
//         height: 60,
//         decoration: const BoxDecoration(
//           color: Colors.red,
//           shape: BoxShape.circle,
//         ),
//         child: const Center(
//           child: Icon(
//             Icons.call_end,
//             color: Colors.white,
//             size: 32,
//           ),
//         ),
//       ),
//     );
//   }
//
//   void _showEndCallConfirmation(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (ctx) => AlertDialog(
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         title: const Text(
//           'End Call',
//           style: TextStyle(fontWeight: FontWeight.w700),
//         ),
//         content: const Text('Are you sure you want to end the consultation?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(ctx).pop(),
//             child: Text(
//               'Cancel',
//               style: TextStyle(color: Colors.grey.shade700),
//             ),
//           ),
//           ElevatedButton(
//             onPressed: () {
//               Navigator.of(ctx).pop();
//               final minimizedCallManager = Get.find<MinimizedCallManager>();
//               minimizedCallManager.endCall();
//               Navigator.of(context).pop();
//             },
//             style: ElevatedButton.styleFrom(
//               backgroundColor: Colors.red,
//               foregroundColor: Colors.white,
//               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//             ),
//             child: const Text('End Call'),
//           ),
//         ],
//       ),
//     );
//   }
// }
