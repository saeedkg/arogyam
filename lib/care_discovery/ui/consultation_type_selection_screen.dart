import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../_shared/consultation/consultation_flow_manager.dart';
import '../../_shared/ui/app_colors.dart';

class ConsultationTypeSelectionScreen extends StatelessWidget {
  final String speciality;

  const ConsultationTypeSelectionScreen({
    super.key,
    required this.speciality,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: Get.back,
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose Consultation Type',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: Colors.black87,
              ),
            ),
            Text(
              speciality,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'How would you like to consult?',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your preferred consultation method',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 32),
              _ConsultationTypeCard(
                appointmentType: AppointmentType.clinic,
                speciality: speciality,
              ),
              const SizedBox(height: 16),
              _ConsultationTypeCard(
                appointmentType: AppointmentType.video,
                speciality: speciality,
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

  const _ConsultationTypeCard({
    required this.appointmentType,
    required this.speciality,
  });

  Color get _backgroundColor {
    switch (appointmentType) {
      case AppointmentType.clinic:
        return AppColors.successGreen.withValues(alpha: 0.1);
      case AppointmentType.video:
        return AppColors.infoBlue.withValues(alpha: 0.1);
    }
  }

  Color get _iconColor {
    switch (appointmentType) {
      case AppointmentType.clinic:
        return AppColors.successGreen;
      case AppointmentType.video:
        return AppColors.infoBlue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          ConsultationFlowManager.instance.navigateWithAppointmentType(
            speciality: speciality,
            appointmentType: appointmentType,
          );
        },
        child: Container(
          height: 160,
          decoration: BoxDecoration(
            color: _backgroundColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade200, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: _iconColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Icon(
                  appointmentType.icon,
                  color: _iconColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      appointmentType.displayName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      appointmentType.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 20,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
