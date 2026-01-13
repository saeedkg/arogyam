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
    return SizedBox(
      height: 100, // Increased height from 90 to 100
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.zero, // Start from the beginning
        itemCount: appointments.length, // No "View All" button
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          final isToday = _isToday(appointment.scheduledAt);
          final isUrgent = _isUrgent(appointment.scheduledAt);
          
          // Determine width based on number of appointments
          double itemWidth;
          if (appointments.length == 1) {
            itemWidth = MediaQuery.of(context).size.width - 40; // Full width for single item
          } else {
            itemWidth = MediaQuery.of(context).size.width - 80; // Partial width to show next item
          }
          
          return Container(
            width: itemWidth,
            margin: EdgeInsets.only(
              left: index == 0 ? 0 : 8, // No left margin for first item
              right: appointments.length == 1 ? 0 : 0, // No right margin
              top: 4, // Reduced from 8 to 4
              bottom: 4, // Reduced from 8 to 4
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white,
                  Colors.grey.shade50,
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppColors.primaryGreen.withOpacity(0.15),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withOpacity(0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 3),
                ),
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  Get.to(() => PendingConsultationScreen(
                    appointmentId: appointment.id.toString(),
                  ));
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(12), // Reduced from 16 to 12
                  child: Row(
                    children: [
                      // Doctor avatar with video icon positioned below
                      Stack(
                        clipBehavior: Clip.none,
                        children: [
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
                              backgroundImage: appointment.doctorImage != null
                                  ? NetworkImage(appointment.doctorImage!)
                                  : null,
                              backgroundColor: Colors.transparent,
                              child: appointment.doctorImage == null
                                  ? Icon(
                                      Icons.medical_services_rounded,
                                      color: AppColors.primaryGreen,
                                      size: 24,
                                    )
                                  : null,
                            ),
                          ),
                          // Video/Clinic icon positioned at bottom right of profile
                          Positioned(
                            bottom: -2,
                            right: -2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: appointment.type == 'online' 
                                      ? [Colors.blue.shade400, Colors.blue.shade600]
                                      : [Colors.green.shade400, Colors.green.shade600],
                                ),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Colors.white,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 1),
                                  ),
                                ],
                              ),
                              child: Icon(
                                appointment.type == 'online' 
                                    ? Icons.videocam_rounded 
                                    : Icons.local_hospital_rounded,
                                size: 12,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      
                      // Appointment details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
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
                                    'Dr. ${appointment.doctorName}',
                                    style: const TextStyle(
                                      fontSize: 16,
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
                            
                            // Time only (shortened)
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
                                    _formatShortAppointmentTime(appointment, isToday),
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.primaryGreen,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // Arrow
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
                ),
              ),
            ),
          );
        },
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

  String _formatShortAppointmentTime(UpcomingAppointment appointment, bool isToday) {
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

  String _formatNextAppointmentTime(UpcomingAppointment appointment) {
    final now = DateTime.now();
    final appointmentDate = appointment.scheduledAt;
    
    if (_isToday(appointmentDate)) {
      return DateTimeFormatter.formatTime(appointmentDate);
    } else if (_isTomorrow(appointmentDate)) {
      return 'Tom';
    } else {
      // Show just the day for future dates
      final daysDiff = appointmentDate.difference(now).inDays;
      if (daysDiff <= 7) {
        return '${daysDiff}d';
      }
      return DateTimeFormatter.formatDate(appointmentDate);
    }
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
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

