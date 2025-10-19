import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../consultation/ui/video_call_screen.dart';
import '../../consultation/utils/permission_handler.dart';
import '../../_shared/ui/app_colors.dart';

class ConsultationConfirmedScreen extends StatelessWidget {
  const ConsultationConfirmedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final name = args?['name'] as String? ?? 'Dr. Priya Sharma';
    final specialization = args?['specialization'] as String? ?? 'General Physician';
    final hospital = args?['hospital'] as String? ?? 'Arogyam Hospital';
    final imageUrl = args?['imageUrl'] as String? ?? 'https://i.pravatar.cc/150?img=52';
    final status = args?['status'] as String? ?? 'Confirmed';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Consultation Confirmed'),
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Success Icon
              // Success Tex

              // Doctor Card
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
                      backgroundImage: NetworkImage(imageUrl),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            specialization,
                            style: TextStyle(
                              color: AppColors.grey600,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            hospital,
                            style: TextStyle(
                              color: AppColors.grey500,
                              fontSize: 13,
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
                        status,
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

              // Join Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => _joinConsultation(
                    context,
                    name: name,
                    specialization: specialization,
                    hospital: hospital,
                    imageUrl: imageUrl,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: AppColors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Join Instant Consultation',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Documents Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.grey200),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.grey100,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: AppColors.infoBlue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(
                            Icons.folder_open_rounded,
                            color: AppColors.infoBlue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Upload Documents',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Share prescriptions or lab reports to help your doctor understand your condition better',
                      style: TextStyle(
                        color: AppColors.grey600,
                        fontSize: 14,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Buttons with improved styling
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.cloud_upload_rounded,
                                        color: AppColors.infoBlue,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Upload File',
                                        style: TextStyle(
                                          color: AppColors.grey700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: AppColors.grey300),
                            ),
                            child: Material(
                              color: AppColors.transparent,
                              child: InkWell(
                                onTap: () {},
                                borderRadius: BorderRadius.circular(12),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.camera_alt_rounded,
                                        color: AppColors.successGreen,
                                        size: 24,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Take Photo',
                                        style: TextStyle(
                                          color: AppColors.grey700,
                                          fontWeight: FontWeight.w500,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              // Support Button
              TextButton(
                onPressed: () {},
                child: const Text(
                  'Need Help? Contact Support',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 20), // Extra bottom padding for safety
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _joinConsultation(BuildContext context, {
    required String name,
    required String specialization,
    required String hospital,
    required String imageUrl,
  }) async {
    // First request permissions
    final permissionsGranted = await PermissionHandler.requestPermissionsWithDialog(context);
    
    if (!permissionsGranted) {
      return; // User denied permissions or there was an error
    }

    // Show confirmation dialog
    final shouldJoin = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Join Consultation'),
          content: const Text(
            'You are about to join the video consultation with the doctor. Make sure you have a stable internet connection.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: AppColors.white,
              ),
              child: const Text('Join'),
            ),
          ],
        );
      },
    );

    if (shouldJoin == true) {
      _navigateToVideoCall(
        name: name,
        specialization: specialization,
        hospital: hospital,
        imageUrl: imageUrl,
      );
    }
  }

  void _navigateToVideoCall({
    required String name,
    required String specialization,
    required String hospital,
    required String imageUrl,
  }) {
    Get.to(
      () => VideoCallScreen(
        doctorName: name,
        specialization: specialization,
        hospital: hospital,
        doctorImageUrl: imageUrl,
      ),
      transition: Transition.rightToLeft,
      duration: const Duration(milliseconds: 300),
    );
  }
}