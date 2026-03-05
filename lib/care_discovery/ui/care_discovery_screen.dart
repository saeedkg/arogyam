import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../_shared/ui/app_colors.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../controller/care_discovery_controller.dart';
import 'components/enhanced_search_bar.dart';
import 'components/popular_specialties_section.dart';
import 'components/common_symptoms_section.dart';
import 'components/health_concerns_section.dart';
import 'components/all_specialties_section.dart';
import 'consultation_type_selection_screen.dart';
import '../entities/common_symptom.dart';
import '../entities/health_concern.dart';

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
  final ScrollController _scrollController = ScrollController();
  final GlobalKey _allSpecialtiesKey = GlobalKey();
  
  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToAllSpecialties() {
    final context = _allSpecialtiesKey.currentContext;
    if (context != null) {
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }
  
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
  
  void _onSymptomSelected(CommonSymptom symptom) {
    // Navigate to the first related specialty
    if (symptom.relatedSpecialties.isNotEmpty) {
      _onSpecializationSelected(symptom.relatedSpecialties.first);
    }
  }
  
  void _onHealthConcernSelected(HealthConcern concern) {
    // Navigate to the related specialty
    _onSpecializationSelected(concern.relatedSpecialty);
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
                    'Loading...',
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
          controller: _scrollController,
          child: Column(
            children: [
              // Enhanced Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: EnhancedSearchBar(
                  preSelectedAppointmentType: widget.preSelectedAppointmentType,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // Popular Specialties Section
              if (c.popularSpecialties.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: PopularSpecialtiesSection(
                    specialties: c.popularSpecialties,
                    preSelectedAppointmentType: widget.preSelectedAppointmentType,
                    onSpecializationSelected: _onSpecializationSelected,
                    onViewAllTapped: _scrollToAllSpecialties,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // Common Symptoms Section
              if (c.commonSymptoms.isNotEmpty)
                CommonSymptomsSection(
                  symptoms: c.commonSymptoms,
                  onSymptomSelected: _onSymptomSelected,
                ),
              
              const SizedBox(height: 24),
              
              // Health Concerns Section
              if (c.healthConcerns.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: HealthConcernsSection(
                    healthConcerns: c.healthConcerns,
                    onConcernSelected: _onHealthConcernSelected,
                  ),
                ),
              
              const SizedBox(height: 24),
              
              // All Specialties Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: c.specializations.isEmpty && !c.isLoading.value
                    ? _buildErrorState(c)
                    : AllSpecialtiesSection(
                        specializations: c.specializations,
                        preSelectedAppointmentType: widget.preSelectedAppointmentType,
                        onSpecializationSelected: _onSpecializationSelected,
                        sectionKey: _allSpecialtiesKey,
                      ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
  
  Widget _buildErrorState(CareDiscoveryController c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.errorRed.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 48,
            color: AppColors.errorRed,
          ),
          const SizedBox(height: 16),
          Text(
            'Failed to load specialties',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your connection and try again',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => c.retryLoadSpecializations(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
