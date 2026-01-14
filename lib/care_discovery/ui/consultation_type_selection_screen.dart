import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../_shared/ui/app_colors.dart';

class ConsultationTypeSelectionScreen extends StatelessWidget {
  final String speciality;

  const ConsultationTypeSelectionScreen({
    super.key,
    required this.speciality,
  });

  void _onConsultationTypeSelected(AppointmentType appointmentType) {
    Navigator.pop(Get.context!, appointmentType);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Same gradient background as dashboard
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.teal,
              AppColors.teal.withOpacity(0.9),
              AppColors.primaryGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Reduced header with gradient background
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                child: Column(
                  children: [
                    // Navigation and title
                    Row(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.arrow_back_ios_rounded, 
                              size: 20,
                              color: Colors.white,
                            ),
                            onPressed: Get.back,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Choose Consultation',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                speciality,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white.withOpacity(0.8),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Main content with white background
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title text about choosing
                        Text(
                          'Select your consultation type',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Choose the option that works best for you',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 24),
                        
                        _ConsultationTypeCard(
                          appointmentType: AppointmentType.clinic,
                          speciality: speciality,
                          onSelected: _onConsultationTypeSelected,
                        ),
                        const SizedBox(height: 20),
                        _ConsultationTypeCard(
                          appointmentType: AppointmentType.video,
                          speciality: speciality,
                          onSelected: _onConsultationTypeSelected,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ConsultationTypeCard extends StatelessWidget {
  final AppointmentType appointmentType;
  final String speciality;
  final Function(AppointmentType) onSelected;

  const _ConsultationTypeCard({
    required this.appointmentType,
    required this.speciality,
    required this.onSelected,
  });

  LinearGradient get _gradient {
    switch (appointmentType) {
      case AppointmentType.clinic:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.blue.shade100,
          ],
        );
      case AppointmentType.video:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.purple.shade100,
          ],
        );
    }
  }

  Color get _iconColor {
    switch (appointmentType) {
      case AppointmentType.clinic:
        return Colors.blue.shade600;
      case AppointmentType.video:
        return Colors.purple.shade600;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _iconColor.withOpacity(0.12),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
            spreadRadius: -1,
          ),
          BoxShadow(
            color: _iconColor.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            onSelected(appointmentType);
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Clean icon container
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _iconColor.withOpacity(0.15),
                      width: 1,
                    ),
                  ),
                  child: Icon(
                    appointmentType.icon,
                    color: _iconColor,
                    size: 26,
                  ),
                ),
                const SizedBox(width: 18),
                
                // Enhanced content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        appointmentType.displayName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        appointmentType.description,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                          fontWeight: FontWeight.w400,
                          height: 1.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                
                // Simple arrow
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: _iconColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: _iconColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
