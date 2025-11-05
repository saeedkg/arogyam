import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../consultation/ui/video_call_screen.dart';
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
    c.load(widget.appointmentId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Consultation'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          if (c.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }
          if (c.error.value != null) {
            return Center(child: Text('Error: ${c.error.value}'));
          }
          if (c.consultation.value == null) {
            return const Center(child: Text('No consultation found'));
          }
          final cons = c.consultation.value!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.grey200,
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 32,
                        backgroundImage: NetworkImage(cons.doctorImageUrl),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              cons.doctorName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              cons.doctorSpecialization,
                              style: TextStyle(
                                color: AppColors.grey600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.successGreen.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          cons.status,
                          style: TextStyle(
                            color: AppColors.successGreen,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: cons.canJoin && cons.authToken != null && cons.meetingRoomName != null
                        ? () => _joinConsultation(context, cons)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: AppColors.white,
                      disabledBackgroundColor: Colors.grey.shade300,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      cons.canJoin ? 'Join Instant Consultation' : 'Not ready to join',
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Future<void> _joinConsultation(BuildContext context, PendingConsultation cons) async {
    final permissionsGranted = await PermissionHandler.requestPermissionsWithDialog(context);
    if (!permissionsGranted) return;

    if (cons.authToken == null || cons.meetingRoomName == null || cons.participantId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to join: Missing join credentials')),
      );
      return;
    }

    final shouldJoin = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Join Consultation'),
        content: const Text('Make sure you have a stable internet connection.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryBlue, foregroundColor: AppColors.white),
            child: const Text('Join'),
          ),
        ],
      ),
    );

    if (shouldJoin == true) {
      // Use the join details from consultation
      Get.to(() => VideoCallScreen(
        doctorName: cons.doctorName,
        specialization: cons.doctorSpecialization,
        hospital: '',
        doctorImageUrl: cons.doctorImageUrl,
        authToken: cons.authToken,
        roomName: cons.meetingRoomName,
        participantId: cons.participantId,
      ));
    }
  }
}

