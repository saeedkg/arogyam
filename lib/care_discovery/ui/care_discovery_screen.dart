import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/routing/routing.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../_shared/ui/app_colors.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../controller/care_discovery_controller.dart';
import 'components/specialization_grid.dart';
import 'search_screen.dart';
import 'consultation_type_selection_screen.dart';

class CareDiscoveryScreen extends StatefulWidget {
  final String entry;
  final AppointmentType? preSelectedAppointmentType;
  
  const CareDiscoveryScreen({
    super.key,
    required this.entry,
    this.preSelectedAppointmentType,
  });

  @override
  State<CareDiscoveryScreen> createState() => _CareDiscoveryScreenState();
}

class _CareDiscoveryScreenState extends State<CareDiscoveryScreen> {
  
  void _onSpecializationSelected(String specialization) {
    // Navigate forward to next screen instead of popping
    if (widget.preSelectedAppointmentType != null) {
      // Appointment type already selected, go directly to doctors
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpecialityDoctorsScreen(
            category: specialization,
            appointmentType: widget.preSelectedAppointmentType,
          ),
        ),
      );
    } else {
      // Need to select consultation type first
      Navigator.push<AppointmentType>(
        context,
        MaterialPageRoute(
          builder: (context) => ConsultationTypeSelectionScreen(
            speciality: specialization,
          ),
        ),
      ).then((appointmentType) {
        if (appointmentType != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => SpecialityDoctorsScreen(
                category: specialization,
                appointmentType: appointmentType,
              ),
            ),
          );
        }
        // If cancelled, stay on current screen (CareDiscoveryScreen remains in stack)
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    final c = Get.put(CareDiscoveryController());
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded, 
              size: 18,
              color: Colors.black87,
            ),
          ),
          onPressed: Get.back,
        ),
        title: Text(
          widget.entry, 
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading specializations...',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // Modern Search Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: GestureDetector(
                  onTap: () => Get.to(() => SearchScreen(
                    preSelectedAppointmentType: widget.preSelectedAppointmentType,
                  )),
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white,
                          AppColors.primaryGreen.withValues(alpha: 0.02),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primaryGreen.withValues(alpha: 0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryGreen.withValues(alpha: 0.08),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        // Search Icon with Gradient Background
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                AppColors.primaryGreen,
                                AppColors.primaryGreen.withValues(alpha: 0.8),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primaryGreen.withValues(alpha: 0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.search_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 16),
                        
                        // Search Content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Search Healthcare',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black87,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Doctors, specialties & symptoms',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey600,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Modern Arrow
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryGreen.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 16,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Specializations Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SpecializationGrid(
                  specializations: c.specializations,
                  preSelectedAppointmentType: widget.preSelectedAppointmentType,
                  onSpecializationSelected: _onSpecializationSelected,
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}
