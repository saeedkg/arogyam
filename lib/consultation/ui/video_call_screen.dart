import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../service/dyte_service.dart';
import '../../_shared/ui/app_colors.dart';

class VideoCallScreen extends StatelessWidget {
  final String doctorName;
  final String specialization;
  final String hospital;
  final String doctorImageUrl;
  final String? authToken;
  final String? roomName;
  final String? participantId;

  const VideoCallScreen({
    super.key,
    required this.doctorName,
    required this.specialization,
    required this.hospital,
    required this.doctorImageUrl,
    this.authToken,
    this.roomName,
    this.participantId,
  });

  @override
  Widget build(BuildContext context) {
    // Validate auth token
    if (authToken == null || authToken!.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.backgroundBlack,
        appBar: AppBar(
          title: const Text('Video Consultation'),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  color: AppColors.errorRed,
                  size: 64,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Unable to Join',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Missing authentication token. Please try again.',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                  ),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }


    return Scaffold(
      backgroundColor: Colors.black,
      body: DyteService.buildMeetingUI(
        authToken: authToken!,
        brandColor: AppColors.primaryGreen,
        backgroundColor: AppColors.backgroundBlack,
      ),
    );

  }
}