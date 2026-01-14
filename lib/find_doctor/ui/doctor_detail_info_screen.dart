import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/routing/app_navigation.dart';
import '../entities/doctor_detail.dart';
import '../controller/doctor_detail_controller.dart';
import '../../booking/ui/doctor_booking_screen.dart';

class DoctorDetailInfoScreen extends StatelessWidget {
  final String doctorId;
  final bool isFromPhysicalAppointment;

  const DoctorDetailInfoScreen({
    super.key,
    required this.doctorId,
    this.isFromPhysicalAppointment = false,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorDetailController());
    
    // Load doctor details when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.load(doctorId);
    });

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20, color: Colors.black87),
          onPressed: () => Get.back(),
        ),
        title:  Text(
           'Doctor Details',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0.5,
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        } else if (controller.detail.value != null) {
          return Stack(
            children: [
              _buildContent(controller.detail.value!),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildBookingButton(context, controller.detail.value!),
              ),
            ],
          );
        } else {
          return _buildErrorState(controller);
        }
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
        strokeWidth: 3,
      ),
    );
  }

  Widget _buildErrorState(DoctorDetailController controller) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Colors.red.shade400,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Unable to load profile',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.grey.shade900,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () => controller.load(doctorId),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Retry',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(DoctorDetail doctorDetail) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildDoctorProfileCard(doctorDetail),
          const SizedBox(height: 16),
         // const SizedBox(height: 16),
          if ((doctorDetail.clinics != null && doctorDetail.clinics!.isNotEmpty) ||
              (doctorDetail.hospitals != null && doctorDetail.hospitals!.isNotEmpty))
            _buildClinicsHospitalsCard(doctorDetail),
          const SizedBox(height: 16),

          _buildAboutAndSpecializationsCard(doctorDetail),
          // const SizedBox(height: 16),
          // _buildConsultationTypesCard(doctorDetail),

          const SizedBox(height: 160), // Space for floating buttons (increased for two buttons)
        ],
      ),
    );
  }

  Widget _buildDoctorProfileCard(DoctorDetail doctorDetail) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Horizontal Layout: Image on Left
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Image with Online Indicator
                Stack(
                  children: [
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primaryBlue.withValues(alpha: 0.15),
                            blurRadius: 16,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.network(
                          doctorDetail.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade100,
                            child: Icon(
                              Icons.person_rounded,
                              size: 50,
                              color: Colors.grey.shade400,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Online Status Indicator
                    if (doctorDetail.availabilityStatus == 'online')
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: Colors.green.shade500,
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.shade500.withValues(alpha: 0.5),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                
                const SizedBox(width: 16),
                
                // Doctor Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Doctor Name
                      Text(
                        doctorDetail.name,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                          letterSpacing: -0.3,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Specialization
                      Text(
                        doctorDetail.specialization,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      
                      const SizedBox(height: 6),
                      
                      // Qualifications
                      if (doctorDetail.qualifications != null && doctorDetail.qualifications!.isNotEmpty)
                        Text(
                          doctorDetail.qualifications!.join(', '),
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey.shade600,
                            height: 1.4,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 20),
            
            // Divider
            Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
            
            const SizedBox(height: 20),
            
            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatItem(
                  Icons.star_rounded,
                  doctorDetail.rating.toStringAsFixed(1),
                  'Rating',
                  Colors.amber.shade600,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade200,
                ),
                _buildStatItem(
                  Icons.work_outline_rounded,
                  '${doctorDetail.experienceYears}+',
                  'Years Exp.',
                  Colors.blue.shade600,
                ),
                Container(
                  width: 1,
                  height: 40,
                  color: Colors.grey.shade200,
                ),
                _buildStatItem(
                  Icons.people_outline_rounded,
                  '${doctorDetail.totalConsultations ?? 0}+',
                  'Patients',
                  Colors.green.shade600,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 26),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildAboutAndSpecializationsCard(DoctorDetail doctorDetail) {
    return _buildCard(
      'About',
      Icons.person_outline_rounded,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Specializations Section
          if (doctorDetail.specializations != null && doctorDetail.specializations!.isNotEmpty) ...[
            const Text(
              'Specializations',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(height: 12),
            _buildSpecializationsContent(doctorDetail),
            const SizedBox(height: 20),
            // Divider
            Container(
              height: 1,
              color: Colors.grey.shade200,
            ),
            const SizedBox(height: 20),
          ],
          
          // About Section
          const Text(
            'About Doctor',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            (doctorDetail.bio.isNotEmpty) ? doctorDetail.bio : 'No information available.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationsContent(DoctorDetail doctorDetail) {
    final specializations = doctorDetail.specializations!;
    
    // Find primary specialization
    final primarySpec = specializations.firstWhere(
      (spec) => spec['is_primary'] == 1,
      orElse: () => specializations.first,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary Specialization
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.primaryBlue.withValues(alpha: 0.1),
                AppColors.primaryBlue.withValues(alpha: 0.05),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryBlue.withValues(alpha: 0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.star_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Primary Specialization',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF666666),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      primarySpec['name'] ?? '',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryBlue,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        
        if (specializations.length > 1) ...[
          const SizedBox(height: 12),
          const Text(
            'Other Specializations',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF666666),
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: specializations
                .where((spec) => spec['is_primary'] != 1)
                .map((spec) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300, width: 1.5),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.local_hospital_rounded,
                      color: Colors.grey.shade600,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      spec['name'] ?? '',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade700,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildConsultationTypesCard(DoctorDetail doctorDetail) {
    if (doctorDetail.consultationTypes == null || doctorDetail.consultationTypes!.isEmpty) {
      return const SizedBox.shrink();
    }

    return _buildCard(
      'Consultation Types',
      Icons.medical_services_outlined,
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: doctorDetail.consultationTypes!.map((type) {
          Color color;
          IconData icon;
          String displayText;
          
          switch (type.toLowerCase()) {
            case 'online':
              color = Colors.blue.shade600;
              icon = Icons.videocam_rounded;
              displayText = 'Video Call';
              break;
            case 'instant':
              color = Colors.green.shade600;
              icon = Icons.chat_bubble_rounded;
              displayText = 'Instant Chat';
              break;
            case 'offline':
              color = Colors.orange.shade600;
              icon = Icons.location_on_rounded;
              displayText = 'In-Person';
              break;
            default:
              color = Colors.grey.shade600;
              icon = Icons.help_outline_rounded;
              displayText = type.toUpperCase();
          }
          
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: color.withValues(alpha: 0.3), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: color, size: 18),
                const SizedBox(width: 8),
                Text(
                  displayText,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildClinicsHospitalsCard(DoctorDetail doctorDetail) {
    final hasClinics = doctorDetail.clinics != null && doctorDetail.clinics!.isNotEmpty;
    final hasHospitals = doctorDetail.hospitals != null && doctorDetail.hospitals!.isNotEmpty;
    final hasOfflineConsultation = doctorDetail.consultationTypes?.any(
      (type) => type.toLowerCase() == 'offline'
    ) ?? false;

    String title = 'Locations';
    if (hasClinics && hasHospitals) {
      title = 'Clinics & Hospitals';
    } else if (hasClinics) {
      title = 'Clinic';
    } else if (hasHospitals) {
      title = 'Hospital';
    }

    return _buildCard(
      title,
      Icons.location_city_rounded,
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clinics Section
          if (hasClinics) ...[
            ...doctorDetail.clinics!.map((clinic) => _buildLocationItem(
              name: clinic['name'] ?? 'Unknown Clinic',
              address: clinic['address'],
              isClinic: true,
            )),
            if (hasHospitals) const SizedBox(height: 16),
          ],
          
          // Hospitals Section
          if (hasHospitals) ...[
            if (hasClinics) ...[
              Container(
                height: 1,
                color: Colors.grey.shade200,
                margin: const EdgeInsets.only(bottom: 16),
              ),
            ],
            ...doctorDetail.hospitals!.map((hospital) => _buildLocationItem(
              name: hospital['name'] ?? 'Unknown Hospital',
              address: hospital['address'],
              isClinic: false,
              hospitalId: hospital['id']?.toString(),
            )),
          ],
          
          // Contact Clinic Button for Offline Consultations
          if (hasOfflineConsultation) ...[

          ],
        ],
      ),
    );
  }

  Widget _buildLocationItem({
    required String name,
    String? address,
    required bool isClinic,
    String? hospitalId,
  }) {
    return InkWell(
      onTap: hospitalId != null && !isClinic 
          ? () => AppNavigation.toHospitalDetail(hospitalId)
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isClinic ? Colors.blue.shade50 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                isClinic ? Icons.local_hospital_rounded : Icons.business_rounded,
                color: isClinic ? Colors.blue.shade600 : Colors.green.shade600,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  if (address != null && address.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (hospitalId != null && !isClinic)
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    } else {
      Get.snackbar(
        'Error',
        'Could not make phone call',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Widget _buildCard(String title, IconData icon, Widget content) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: AppColors.primaryBlue,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildBookingButton(BuildContext context, DoctorDetail doctorDetail) {
    final hasOnlineConsultation = doctorDetail.hasInstantOrOnlineConsultation;
    final hasOfflineConsultation = doctorDetail.consultationTypes?.any(
      (type) => type.toLowerCase() == 'offline'
    ) ?? false;

    // If no consultation types available, don't show buttons
    if (!hasOnlineConsultation && !hasOfflineConsultation) {
      return const SizedBox.shrink();
    }

    // If both types available, show two buttons with priority based on source
    if (hasOnlineConsultation && hasOfflineConsultation) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 8,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          children: [
            // First Button - Priority based on isFromPhysicalAppointment
            if (isFromPhysicalAppointment) ...[
              // Call Clinic Button (Primary when from physical)
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _makePhoneCall('+911234567890'); // Replace with actual clinic number
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Call Clinic For Book Appointments',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Book Video Consultation Button (Secondary when from physical)
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryBlue,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorBookingScreen(
                          doctorId: doctorDetail.id.toString(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.videocam_rounded, color: AppColors.primaryBlue, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Book Video Consult - ₹${doctorDetail.consultationFee ?? doctorDetail.fee}',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryBlue,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ] else ...[
              // Book Video Consultation Button (Primary when from video)
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primaryGreen,
                      AppColors.primaryGreen.withValues(alpha: 0.8),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primaryGreen.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => DoctorBookingScreen(
                          doctorId: doctorDetail.id.toString(),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.videocam_rounded, color: Colors.white, size: 20),
                      const SizedBox(width: 10),
                      Text(
                        'Book Video Consult - ₹${doctorDetail.consultationFee ?? doctorDetail.fee}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // Call Clinic Button (Secondary when from video)
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.primaryGreen,
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ElevatedButton(
                  onPressed: () {
                    _makePhoneCall('+911234567890'); // Replace with actual clinic number
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.phone_rounded, color: AppColors.primaryGreen, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Call Clinic',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primaryGreen,
                          letterSpacing: -0.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    // If only online consultation, show Book Consultation button
    if (hasOnlineConsultation) {
      return Container(
        width: double.infinity,
        height: 56,
        margin: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.primaryGreen,
              AppColors.primaryGreen.withValues(alpha: 0.8),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryGreen.withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoctorBookingScreen(
                  doctorId: doctorDetail.id.toString(),
                ),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.calendar_today_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Text(
                'Book Video Consult - ₹${doctorDetail.consultationFee ?? doctorDetail.fee}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: -0.3,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If only offline consultation, show Call Clinic button
    return Container(
      width: double.infinity,
      height: 56,
      margin: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 16,
        bottom: MediaQuery.of(context).padding.bottom + 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryGreen,
            AppColors.primaryGreen.withValues(alpha: 0.8),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          _makePhoneCall('+911234567890'); // Replace with actual clinic number
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.phone_rounded, color: Colors.white, size: 20),
            SizedBox(width: 10),
            Text(
              'Call Clinic',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}