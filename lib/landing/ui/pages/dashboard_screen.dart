import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../../_shared/ui/app_text.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/utils/date_time_formatter.dart';
import '../../../care_discovery/ui/care_discovery_screen.dart';
import '../../../care_discovery/ui/search_screen.dart';
import '../../../instant_consultation/ui/instant_consult_screen.dart';
import '../../../consultation_pending/ui/pending_consultation_screen.dart';
import '../components/banner_carousal.dart';
import '../components/dasbboard_category.dart';
import '../components/dashboard_app_bar.dart';
import '../components/dashboard_quick_action_view.dart' show QuickActions;
import '../components/dashboard_serach_view.dart';
import '../components/top_doctors_view.dart';
import '../components/upcoming_appointments_section.dart';
import '../components/monsoon_care_tips_card.dart';
import '../components/search_and_categories_row.dart';
import '../components/top_specialities_horizontal.dart';
import '../all_categories_screen.dart';
import '../../entities/dashboard_data.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      body: Container(
        // Same gradient background for entire screen
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
        child: RefreshIndicator(
          onRefresh: controller.loadAll,
          color: Colors.white,
          backgroundColor: AppColors.primaryGreen,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            slivers: [
              // Fixed header with teal/green gradient (no collapsing)
              SliverToBoxAdapter(
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 60), // Increased bottom padding for more green area
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Header with app name and search icon
                              Row(
                                children: [
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Ask It',
                                        style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const Text(
                                        'Doctor in minutes',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const Spacer(),
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: IconButton(
                                      onPressed: () {
                                        // Handle notification action
                                        // TODO: Navigate to notifications screen
                                      },
                                      icon: const Icon(
                                        Icons.notifications_outlined,
                                        color: Colors.white,
                                        size: 22,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              
                              // Search bar and categories in same row
                              const SearchAndCategoriesRow(),
                              const SizedBox(height: 20),
                              
                              // Quick Actions inside green area
                              const _OriginalQuickActions(),
                            ],
                          ),
                        ),
                      ),
                    ),
                    // Monsoon Care Tips positioned in between (overlapping edge)
                    Positioned(
                      left: 20,
                      right: 20,
                      bottom: -40, // Position so half is in green, half will be in white
                      child: const MonsoonCareTipsCard(),
                    ),
                  ],
                ),
              ),
              
              // Main content with white background starting from green area
              SliverToBoxAdapter(
                child: Obx(() {
                  if (controller.isLoading.value) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height - 200,
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppColors.primaryGreen,
                        ),
                      ),
                    );
                  }
                  return Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Spacing for overlapping Monsoon card
                       // const SizedBox(height: 50),

                        // Upcoming Appointments Section (if any)
                        Obx(() {
                          if (controller.upcomingAppointments.isNotEmpty) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 50),
                                  _SectionHeader(title: 'Upcoming Appointments'),
                                  const SizedBox(height: 16),
                                  _UpcomingAppointmentsCard(appointments: controller.upcomingAppointments),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            );
                          }
                          return const SizedBox(height: 50);
                        }),

                        // Top Specialities with rounded white background
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _SectionHeader(
                                title: 'Medical Specialties',
                                onSeeAllPressed: () {
                                  // Navigate to full categories list
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AllCategoriesScreen(categories: controller.categories),
                                    ),
                                  );
                                },
                              ),
                              const SizedBox(height: 16),
                              TopSpecialitiesHorizontal(categories: controller.categories),
                            ],
                          ),
                        ),
                    const SizedBox(height: 24),

                    // Top doctors
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _SectionHeader(title: 'Featured Doctors'),
                          const SizedBox(height: 16),
                          TopDoctors(doctors: controller.topDoctors),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Extra bottom padding for floating widget
                      ],
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
      ),
      // Floating appointment widget
      floatingActionButton: Obx(() {
        if (controller.upcomingAppointments.isEmpty) {
          return const SizedBox.shrink();
        }
        return FloatingAppointmentWidget(
          appointments: controller.upcomingAppointments,
        );
      }),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAllPressed;
  const _SectionHeader({required this.title, this.onSeeAllPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            letterSpacing: -0.3,
          ),
        ),
        const Spacer(),
        if (onSeeAllPressed != null)
          TextButton(
            onPressed: onSeeAllPressed,
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Text(
              'See all',
              style: TextStyle(
                color: AppColors.primaryGreen,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
      ],
    );
  }
}

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 180,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Blob shapes for decoration
          Positioned(
            top: -30,
            right: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                borderRadius: BorderRadius.circular(50),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.primaryGreen.withOpacity(0.1),
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Consult a Doctor',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const Text(
                        'Online, Anytime, and',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const Text(
                        'Anywhere',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Book Now',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Container(
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.medical_services_rounded,
                        size: 60,
                        color: AppColors.primaryGreen,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OriginalQuickActions extends StatelessWidget {
  const _OriginalQuickActions();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.calendar_today_rounded,
                  title: 'Hospital\nAppointment',
                  color: const Color(0xFF7DD3FC),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF93C5FD), // Lighter blue
                      Color(0xFF7DD3FC), // Medium blue
                      Color(0xFF60A5FA), // Deeper blue
                    ],
                  ),
                  type: _QuickActionType.hospitalAppointment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.videocam_rounded,
                  title: 'Video Consult',
                  color: const Color(0xFFC4B5FD),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFDDD6FE), // Lighter purple
                      Color(0xFFC4B5FD), // Medium purple
                      Color(0xFFA78BFA), // Deeper purple
                    ],
                  ),
                  type: _QuickActionType.videoConsult,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.bolt_rounded,
                  title: 'Instant\nConsult',
                  color: const Color(0xFFFDB68A),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFFED7AA), // Lighter orange
                      Color(0xFFFDB68A), // Medium orange
                      Color(0xFFFB923C), // Deeper orange
                    ],
                  ),
                  type: _QuickActionType.instantConsult,
                ),
              ),
            ],
          ),
        ],
      );
  }
}

enum _QuickActionType {
  hospitalAppointment,
  videoConsult,
  instantConsult,
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  final Gradient gradient;
  final _QuickActionType type;

  const _QuickActionCard({
    required this.icon,
    required this.title,
    required this.color,
    required this.gradient,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(20),
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () {
          switch (type) {
            case _QuickActionType.videoConsult:
              // Direct navigation to CareDiscoveryScreen with pre-selected appointment type
              Get.to(() => const CareDiscoveryScreen(
                entry: 'Video Consultation',
                // preSelectedAppointmentType: AppointmentType.video,
              ));
              break;
            case _QuickActionType.instantConsult:
              // Direct navigation to instant consultation
              Get.to(() => const InstantConsultScreen());
              break;
            case _QuickActionType.hospitalAppointment:
              // Direct navigation to CareDiscoveryScreen with pre-selected appointment type
              Get.to(() => const CareDiscoveryScreen(
                entry: 'Hospital Appointment',
                // preSelectedAppointmentType: AppointmentType.clinic,
              ));
              break;
          }
        },
        highlightColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.2),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 32,
              ),
              const Spacer(),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  height: 1.2,
                ),
                maxLines: 2,
                overflow: TextOverflow.visible,
              ),
            ],
          ),
        ),
      ),
    );
  }
}






class _UpcomingAppointmentsCard extends StatelessWidget {
  final List<UpcomingAppointment> appointments;

  const _UpcomingAppointmentsCard({required this.appointments});

  @override
  Widget build(BuildContext context) {
    // Show only the first appointment for minimal height
    final nextAppointment = appointments.first;
    final isToday = _isToday(nextAppointment.scheduledAt);
    final isUrgent = _isUrgent(nextAppointment.scheduledAt);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.15),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Navigate to appointment details
            Get.to(() => PendingConsultationScreen(
              appointmentId: nextAppointment.id.toString(),
            ));
          },
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                // Doctor avatar - enhanced design
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primaryGreen.withOpacity(0.1),
                        AppColors.primaryGreen.withOpacity(0.05),
                      ],
                    ),
                    border: Border.all(
                      color: AppColors.primaryGreen.withOpacity(0.3),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.primaryGreen.withOpacity(0.15),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: CircleAvatar(
                    radius: 23,
                    backgroundImage: nextAppointment.doctorImage != null
                        ? NetworkImage(nextAppointment.doctorImage!)
                        : null,
                    backgroundColor: Colors.transparent,
                    child: nextAppointment.doctorImage == null
                        ? Icon(
                            Icons.medical_services_rounded,
                            color: AppColors.primaryGreen,
                            size: 24,
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 16),
                
                // Appointment details - enhanced layout
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Doctor name with urgency indicator
                      Row(
                        children: [
                          if (isUrgent)
                            Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: Colors.orange,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.orange.withOpacity(0.4),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Text(
                              'Dr. ${nextAppointment.doctorName}',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w700,
                                color: Colors.black87,
                                letterSpacing: -0.2,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      
                      // Time and type in enhanced row
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.primaryGreen.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.access_time_rounded,
                                  size: 12,
                                  color: AppColors.primaryGreen,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  _formatAppointmentTime(nextAppointment, isToday),
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.primaryGreen,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: nextAppointment.type == 'online' 
                                    ? [Colors.blue.shade50, Colors.blue.shade100]
                                    : [Colors.green.shade50, Colors.green.shade100],
                              ),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: nextAppointment.type == 'online' 
                                    ? Colors.blue.withOpacity(0.3)
                                    : Colors.green.withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            child: Icon(
                              nextAppointment.type == 'online' 
                                  ? Icons.videocam_rounded 
                                  : Icons.local_hospital_rounded,
                              size: 14,
                              color: nextAppointment.type == 'online' 
                                  ? Colors.blue.shade700
                                  : Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                // Enhanced right side with counter and arrow
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (appointments.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.primaryGreen,
                              AppColors.primaryGreen.withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryGreen.withOpacity(0.3),
                              blurRadius: 6,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          '+${appointments.length - 1}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatAppointmentTime(UpcomingAppointment appointment, bool isToday) {
    if (isToday) {
      return 'Today ${DateTimeFormatter.formatTime(appointment.scheduledAt)}';
    } else {
      final now = DateTime.now();
      final tomorrow = now.add(const Duration(days: 1));
      
      if (appointment.scheduledAt.year == tomorrow.year &&
          appointment.scheduledAt.month == tomorrow.month &&
          appointment.scheduledAt.day == tomorrow.day) {
        return 'Tom ${DateTimeFormatter.formatTime(appointment.scheduledAt)}';
      }
      
      return DateTimeFormatter.formatDate(appointment.scheduledAt);
    }
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool _isUrgent(DateTime date) {
    final now = DateTime.now();
    final difference = date.difference(now);
    return difference.inHours <= 2 && difference.inHours >= 0;
  }
}

