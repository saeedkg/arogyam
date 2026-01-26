// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:get/get.dart';
// import 'package:realtimekit_core/realtimekit_core.dart';
// import '../controller/realtimekit_video_call_controller.dart';
// import '../controller/minimized_call_manager.dart';
// import '../../_shared/ui/app_colors.dart';
//
// /// A floating widget that displays a minimized video call
// class MinimizedCallWidget extends StatefulWidget {
//   final RealtimeKitVideoCallController controller;
//   final VoidCallback onTap;
//   final VoidCallback onClose;
//   final Offset position;
//   final Function(Offset) onDragUpdate;
//   final String formattedDuration;
//
//   const MinimizedCallWidget({
//     super.key,
//     required this.controller,
//     required this.onTap,
//     required this.onClose,
//     required this.position,
//     required this.onDragUpdate,
//     required this.formattedDuration,
//   });
//
//   @override
//   State<MinimizedCallWidget> createState() => _MinimizedCallWidgetState();
// }
//
// class _MinimizedCallWidgetState extends State<MinimizedCallWidget>
//     with SingleTickerProviderStateMixin {
//   bool _isDragging = false;
//   late AnimationController _scaleController;
//   late Animation<double> _scaleAnimation;
//
//   @override
//   void initState() {
//     super.initState();
//     _scaleController = AnimationController(
//       duration: const Duration(milliseconds: 100),
//       vsync: this,
//     );
//     _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
//       CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _scaleController.dispose();
//     super.dispose();
//   }
//
//   void _handleTapDown(TapDownDetails details) {
//     _scaleController.forward();
//     HapticFeedback.lightImpact();
//   }
//
//   void _handleTapUp(TapUpDetails details) {
//     _scaleController.reverse();
//   }
//
//   void _handleTapCancel() {
//     _scaleController.reverse();
//   }
//
//   void _handleTap() {
//     HapticFeedback.mediumImpact();
//     widget.onTap();
//   }
//
//   void _handleLongPressStart(LongPressStartDetails details) {
//     setState(() {
//       _isDragging = true;
//     });
//     HapticFeedback.heavyImpact();
//   }
//
//   void _handleLongPressMoveUpdate(LongPressMoveUpdateDetails details) {
//     if (_isDragging) {
//       widget.onDragUpdate(details.globalPosition - const Offset(60, 80));
//     }
//   }
//
//   void _handleLongPressEnd(LongPressEndDetails details) {
//     setState(() {
//       _isDragging = false;
//     });
//     HapticFeedback.lightImpact();
//
//     // Trigger snap animation
//     final screenSize = MediaQuery.of(context).size;
//     final manager = Get.find<MinimizedCallManager>();
//     manager.animateSnapToCorner(widget.position, screenSize);
//   }
//
//   void _handleCloseButtonTap() {
//     HapticFeedback.mediumImpact();
//     widget.onClose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Positioned(
//       left: widget.position.dx,
//       top: widget.position.dy,
//       child: Semantics(
//         label: 'Minimized video call. Tap to expand, long press to drag.',
//         button: true,
//         child: ScaleTransition(
//           scale: _scaleAnimation,
//           child: GestureDetector(
//             onTapDown: _handleTapDown,
//             onTapUp: _handleTapUp,
//             onTapCancel: _handleTapCancel,
//             onTap: _handleTap,
//             onLongPressStart: _handleLongPressStart,
//             onLongPressMoveUpdate: _handleLongPressMoveUpdate,
//             onLongPressEnd: _handleLongPressEnd,
//             child: Container(
//               width: 120,
//               height: 160,
//               decoration: BoxDecoration(
//                 color: Colors.black,
//                 borderRadius: BorderRadius.circular(12),
//                 border: Border.all(
//                   color: Colors.white.withValues(alpha: 0.3),
//                   width: 2,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: 0.5),
//                     blurRadius: 12,
//                     offset: const Offset(0, 6),
//                   ),
//                 ],
//               ),
//               child: ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: Stack(
//                   children: [
//                     // Video feed
//                     _buildVideoFeed(),
//
//                     // Gradient overlay for better text visibility
//                     Positioned(
//                       bottom: 0,
//                       left: 0,
//                       right: 0,
//                       child: Container(
//                         height: 60,
//                         decoration: BoxDecoration(
//                           gradient: LinearGradient(
//                             begin: Alignment.bottomCenter,
//                             end: Alignment.topCenter,
//                             colors: [
//                               Colors.black.withValues(alpha: 0.8),
//                               Colors.transparent,
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     // Status indicators and duration
//                     Positioned(
//                       bottom: 8,
//                       left: 8,
//                       right: 8,
//                       child: _buildStatusBar(),
//                     ),
//
//                     // Close button
//                     Positioned(
//                       top: 4,
//                       right: 4,
//                       child: _buildCloseButton(),
//                     ),
//
//                     // Dragging indicator
//                     if (_isDragging)
//                       Positioned.fill(
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: Colors.white.withValues(alpha: 0.1),
//                             borderRadius: BorderRadius.circular(10),
//                             border: Border.all(
//                               color: AppColors.primaryGreen,
//                               width: 2,
//                             ),
//                           ),
//                         ),
//                       ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildVideoFeed() {
//     return Obx(() {
//       final service = widget.controller.service;
//       final participants = service?.participants;
//       final isConnected = widget.controller.isConnected.value;
//
//       // Try to get remote participant
//       RtkMeetingParticipant? remoteParticipant;
//
//       if (isConnected && service != null && participants != null) {
//         if (participants.active.isNotEmpty) {
//           remoteParticipant = participants.active.first;
//         } else if (participants.joined.isNotEmpty) {
//           remoteParticipant = participants.joined.first;
//         }
//       }
//
//       // Show video if available
//       if (remoteParticipant != null && remoteParticipant.videoEnabled) {
//         return SizedBox(
//           width: 120,
//           height: 160,
//           child: VideoView(
//             key: ValueKey('minimized_remote_${remoteParticipant.id}'),
//             meetingParticipant: remoteParticipant,
//             isSelfParticipant: false,
//           ),
//         );
//       }
//
//       // Show profile picture placeholder
//       return Container(
//         width: 120,
//         height: 160,
//         color: Colors.grey.shade900,
//         child: Center(
//           child: Column(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               CircleAvatar(
//                 radius: 30,
//                 backgroundImage: NetworkImage(widget.controller.doctorImageUrl),
//                 backgroundColor: Colors.grey.shade800,
//               ),
//               const SizedBox(height: 8),
//               Text(
//                 widget.controller.doctorName,
//                 style: const TextStyle(
//                   color: Colors.white,
//                   fontSize: 12,
//                   fontWeight: FontWeight.w600,
//                 ),
//                 textAlign: TextAlign.center,
//                 maxLines: 2,
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ],
//           ),
//         ),
//       );
//     });
//   }
//
//   Widget _buildStatusBar() {
//     return Obx(() {
//       final isConnected = widget.controller.isConnected.value;
//       final isAudioMuted = !widget.controller.isAudioEnabled.value;
//       final isVideoDisabled = !widget.controller.isVideoEnabled.value;
//
//       return Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           // Status indicators
//           Row(
//             children: [
//               // Connection indicator
//               if (isConnected)
//                 _PulsingDot(color: AppColors.successGreen),
//               if (isConnected) const SizedBox(width: 4),
//
//               // Muted indicator
//               if (isAudioMuted)
//                 const Icon(
//                   Icons.mic_off,
//                   color: Colors.white,
//                   size: 14,
//                 ),
//               if (isAudioMuted) const SizedBox(width: 4),
//
//               // Video disabled indicator
//               if (isVideoDisabled)
//                 const Icon(
//                   Icons.videocam_off,
//                   color: Colors.white,
//                   size: 14,
//                 ),
//             ],
//           ),
//
//           // Duration
//           Text(
//             widget.formattedDuration,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 12,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       );
//     });
//   }
//
//   Widget _buildCloseButton() {
//     return Semantics(
//       label: 'End call',
//       button: true,
//       child: GestureDetector(
//         onTap: _handleCloseButtonTap,
//         child: Container(
//           width: 44,
//           height: 44,
//           alignment: Alignment.topRight,
//           padding: const EdgeInsets.all(8),
//           child: Container(
//             width: 28,
//             height: 28,
//             decoration: BoxDecoration(
//               color: Colors.red.withValues(alpha: 0.9),
//               shape: BoxShape.circle,
//             ),
//             child: const Icon(
//               Icons.close,
//               color: Colors.white,
//               size: 16,
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
//
// /// A pulsing dot indicator for connection status
// class _PulsingDot extends StatefulWidget {
//   final Color color;
//
//   const _PulsingDot({required this.color});
//
//   @override
//   State<_PulsingDot> createState() => _PulsingDotState();
// }
//
// class _PulsingDotState extends State<_PulsingDot>
//     with SingleTickerProviderStateMixin {
//   late AnimationController _controller;
//   late Animation<double> _animation;
//
//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(
//       duration: const Duration(milliseconds: 1000),
//       vsync: this,
//     )..repeat(reverse: true);
//     _animation = Tween<double>(begin: 1.0, end: 0.5).animate(
//       CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
//     );
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return FadeTransition(
//       opacity: _animation,
//       child: Container(
//         width: 8,
//         height: 8,
//         decoration: BoxDecoration(
//           color: widget.color,
//           shape: BoxShape.circle,
//         ),
//       ),
//     );
//   }
// }
