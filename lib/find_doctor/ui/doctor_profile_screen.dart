import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/ui/app_colors.dart';
import '../../_shared/routing/app_navigation.dart';
import '../entities/doctor_detail.dart';
import '../controller/doctor_detail_controller.dart';

class DoctorProfileScreen extends StatelessWidget {
  final String doctorId;

  const DoctorProfileScreen({
    super.key,
    required this.doctorId,
  });

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(DoctorDetailController());
    
    // Load doctor details when screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.load(doctorId);
    });

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Obx(() {
        if (controller.isLoading.value) {
          return _buildLoadingState();
        } else if (controller.detail.value != null) {
          return _buildContent(controller.detail.value!);
        } else {
          return _buildErrorState(controller);
        }
      }),
      bottomNavigationBar: Obx(() {
        if (controller.isLoading.value || controller.detail.value == null) {
          return const SizedBox.shrink();
        }
        return _buildBookingButton(controller.detail.value!);
      }),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.primaryBlue,
        strokeWidth: 2.5,
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
    return CustomScrollView(
      slivers: [
        _buildAppBar(doctorDetail),
        SliverToBoxAdapter(
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildDoctorProfileCard(doctorDetail),
              const SizedBox(height: 16),
              _buildInfoSection(doctorDetail),
              const SizedBox(height: 100), // Space for bottom button
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppBar(DoctorDetail doctorDetail) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.only(left: 8),
        child: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.arrow_back_rounded, size: 20),
          ),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 8),
          child: IconButton(
            onPressed: () {
              // Add to favorites functionality
            },
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.favorite_border_rounded, size: 20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorProfileCard(DoctorDetail doctorDetail) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Profile Image with Status
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primaryBlue.withValues(alpha: 0.2),
                    width: 4,
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
                    errorBuilder: (_, __, ___) => _buildDefaultAvatar(),
                  ),
                ),
              ),
              // Online Status Badge
              if (doctorDetail.availabilityStatus == 'online')
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.green.shade500,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                    ),
                  ),
                ),
              // Verification Badge
              if (doctorDetail.isVerified == true)
                Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primaryBlue.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified_rounded,
                      color: Colors.white,
                      size: 16,
                    ),
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Doctor Name
          Text(
            doctorDetail.name,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 6),
          
          // Specialization
          Text(
            doctorDetail.specialization,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryBlue,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 4),
          
          // Qualifications
          if (doctorDetail.qualifications != null && doctorDetail.qualifications!.isNotEmpty)
            Text(
              doctorDetail.qualifications!.join(', '),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          
          const SizedBox(height: 24),
          
          // Divider
          Container(
            height: 1,
            color: Colors.grey.shade200,
          ),
          
          const SizedBox(height: 24),
          
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
    );
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: Colors.grey.shade100,
      child: Icon(
        Icons.person_rounded,
        size: 60,
        color: Colors.grey.shade400,
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

  Widget _buildInfoSection(DoctorDetail doctorDetail) {
    return Column(
      children: [
        _buildAboutCard(doctorDetail),
        const SizedBox(height: 16),
        if (doctorDetail.consultationTypes != null && doctorDetail.consultationTypes!.isNotEmpty)
          _buildConsultationTypesCard(doctorDetail),
        const SizedBox(height: 16),
        if (doctorDetail.languages != null && doctorDetail.languages!.isNotEmpty)
          _buildLanguagesCard(doctorDetail),
        const SizedBox(height: 16),
        _buildAvailabilityCard(doctorDetail),
      ],
    );
  }

  Widget _buildAboutCard(DoctorDetail doctorDetail) {
    return _buildCard(
      'About',
      Icons.info_outline_rounded,
      Text(
        (doctorDetail.bio.isNotEmpty) ? doctorDetail.bio : 'No information available.',
        style: TextStyle(
          fontSize: 15,
          color: Colors.grey.shade700,
          height: 1.6,
        ),
      ),
    );
  }

  Widget _buildConsultationTypesCard(DoctorDetail doctorDetail) {
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

  Widget _buildLanguagesCard(DoctorDetail doctorDetail) {
    return _buildCard(
      'Languages',
      Icons.language_rounded,
      Wrap(
        spacing: 10,
        runSpacing: 10,
        children: doctorDetail.languages!.map((language) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300, width: 1.5),
            ),
            child: Text(
              language,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAvailabilityCard(DoctorDetail doctorDetail) {
    final isOnline = doctorDetail.availabilityStatus == 'online';
    
    return _buildCard(
      'Availability',
      Icons.schedule_rounded,
      Column(
        children: [
          // Online Status
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: isOnline ? Colors.green.shade50 : Colors.grey.shade50,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isOnline ? Colors.green.shade200 : Colors.grey.shade200,
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: isOnline ? Colors.green.shade500 : Colors.grey.shade400,
                    shape: BoxShape.circle,
                    boxShadow: isOnline ? [
                      BoxShadow(
                        color: Colors.green.shade500.withValues(alpha: 0.4),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ] : [],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    isOnline ? 'Currently Online' : 'Currently Offline',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isOnline ? Colors.green.shade700 : Colors.grey.shade700,
                    ),
                  ),
                ),
                if (doctorDetail.availableToday == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primaryBlue,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          
          if (doctorDetail.todaySlotsCount != null && doctorDetail.todaySlotsCount! > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.blue.shade200, width: 1.5),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    color: Colors.blue.shade600,
                    size: 22,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    '${doctorDetail.todaySlotsCount} slots available today',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCard(String title, IconData icon, Widget content) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
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
    );
  }

  Widget _buildBookingButton(DoctorDetail doctorDetail) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: () => AppNavigation.toDoctorBooking(doctorDetail.id.toString()),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              elevation: 0,
              shadowColor: AppColors.primaryBlue.withValues(alpha: 0.4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 20),
                const SizedBox(width: 10),
                Text(
                  'Book Consultation - ₹${doctorDetail.consultationFee ?? doctorDetail.fee}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
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