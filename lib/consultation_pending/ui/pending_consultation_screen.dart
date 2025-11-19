import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import '../../consultation/ui/realtimekit_video_call_screen.dart';
import '../../consultation/entities/video_call_config.dart';
import '../../consultation/utils/permission_handler.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/pending_consultation_controller.dart';
import '../entities/pending_consultation.dart';

class PendingConsultationScreen extends StatefulWidget {
  final String appointmentId;
  const PendingConsultationScreen({super.key, required this.appointmentId});

  @override
  State<PendingConsultationScreen> createState() => _PendingConsultationScreenState();
}

class _PendingConsultationScreenState extends State<PendingConsultationScreen> {
  final c = Get.put(PendingConsultationController());


  @override
  void initState() {
    super.initState();
    _loadConsultation();
  }

  Future<void> _loadConsultation() async {
    await c.load(widget.appointmentId);
  }

  @override
  void dispose() {
    super.dispose();
  }



  Future<void> _joinConsultation() async {
    if (c.consultation.value == null) return;
    
    final cons = c.consultation.value!;
    if (!cons.canJoin || cons.authToken == null || cons.meetingRoomName == null || cons.participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to join: Missing join credentials'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final permissionsGranted = await PermissionHandler.requestPermissionsWithDialog(context);
    if (!permissionsGranted || !mounted) return;

    if (!mounted) return;
    final shouldJoin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Join Consultation',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: const Text('Make sure you have a stable internet connection.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey.shade700),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (shouldJoin == true && mounted) {
      final config = VideoCallConfig(
        authToken: cons.authToken!,
        roomName: cons.meetingRoomName!,
        participantId: cons.participantId!,
        doctorName: cons.doctorName ?? 'Doctor',
        specialization: cons.doctorSpecialization ?? 'General',
        doctorImageUrl: cons.doctorImageUrl,
      );
      
      Get.to(() => RealtimeKitVideoCallScreen(config: config));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Consultation',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
      ),
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (c.error.value != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.grey.shade900,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      c.error.value!,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: _loadConsultation,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryGreen,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (c.consultation.value == null) {
            return const Center(
              child: Text('No consultation found'),
            );
          }

          final cons = c.consultation.value!;

          // Show waiting room if no doctor assigned
          if (cons.isWaitingForDoctor) {
            return Container();
          }

          // Show consultation ready view when doctor is assigned
          return _buildConsultationReady(cons);
        }),
      ),
    );
  }



  Widget _buildConsultationReady(PendingConsultation cons) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Combined Card with Doctor Info and Consultation Details
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                // Status Badge at Top
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.successGreen.withOpacity(0.05),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 18,
                        color: AppColors.successGreen,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Doctor Assigned',
                        style: TextStyle(
                          color: AppColors.successGreen,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Divider(height: 1, color: Colors.grey.shade200),
                
                // Doctor Info Row (Full Width)
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      // Doctor Avatar
                      Stack(
                        children: [
                          Container(
                            width: 70,
                            height: 70,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.3),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 33,
                              backgroundImage: NetworkImage(cons.doctorImageUrl),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: AppColors.successGreen,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                              ),
                              child: const Icon(
                                Icons.check,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Doctor Name and Specialization
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cons.doctorName ?? 'Doctor',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: Colors.grey.shade900,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                Icon(
                                  Icons.medical_services_rounded,
                                  size: 16,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cons.doctorSpecialization ?? 'General',
                                  style: TextStyle(
                                    fontSize: 15,
                                    color: Colors.grey.shade600,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Divider
                Divider(height: 1, color: Colors.grey.shade200),
                
                // Consultation Details
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultation Details',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey.shade900,
                        ),
                      ),
                      const SizedBox(height: 20),
                      _buildDetailRow(
                        icon: Icons.calendar_today_rounded,
                        label: 'Date',
                        value: _formatDate(cons.scheduledAt),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.access_time_rounded,
                        label: 'Time',
                        value: _formatTime(cons.scheduledAt),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        icon: Icons.video_call_rounded,
                        label: 'Type',
                        value: 'Video Consultation',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Join Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: cons.canJoin && cons.authToken != null && cons.meetingRoomName != null
                  ? _joinConsultation
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 0,
                shadowColor: Colors.transparent,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (cons.canJoin) ...[
                    const Icon(Icons.video_call_rounded, size: 24),
                    const SizedBox(width: 12),
                  ],
                  Text(
                    cons.canJoin ? 'Join Consultation' : 'Waiting for consultation to start...',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryGreen.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 20, color: AppColors.primaryGreen),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade900,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[date.month - 1]} ${date.day}, ${date.year}';
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : (date.hour == 0 ? 12 : date.hour);
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }
}
