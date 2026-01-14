import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../../../_shared/consultation/consultation_type.dart';
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
import '../components/upcoming_appointments_card.dart';
import '../components/monsoon_care_tips_card.dart';
import '../components/search_and_categories_row.dart';
import '../components/top_specialities_horizontal.dart';
import '../all_categories_screen.dart';
import '../../entities/dashboard_data.dart';
import '../components/upcoming_appointments_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Set transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    
    final controller = Get.find<HomeController>();
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value) {
          // Show only loading screen when data is loading
          return Container(
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
                  // Simple header during loading
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                    child: Row(
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
                            onPressed: null, // Disabled during loading
                            icon: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 22,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Loading content
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20),
                          topRight: Radius.circular(20),
                        ),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: AppColors.primaryGreen.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: CircularProgressIndicator(
                                  color: AppColors.primaryGreen,
                                  strokeWidth: 3,
                                ),
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Loading your health dashboard...',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey.shade700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Getting your appointments and doctors ready',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: Colors.grey.shade500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        // Show full dashboard when data is loaded
        return Container(
          // Gradient background with green variants - darker on right, lighter on left
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                const Color(0xFF5A9C8E), // Lighter teal-green on left
                const Color(0xFF4A8B7E), // Medium green
                const Color(0xFF3A7A6E), // Darker green on right
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
                  child: Container(
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
                                  const SizedBox(height: 60),
                                  _SectionHeader(title: 'Upcoming Appointments'),
                                  const SizedBox(height: 16),
                                  UpcomingAppointmentsCard(appointments: controller.upcomingAppointments),
                                  const SizedBox(height: 16),
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
                                title: 'Top Specialties',
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
                  ),
                ),
              ],
            ),
          ),
        );
      }),
      // Floating appointment widget
      // floatingActionButton: Obx(() {
      //   if (controller.upcomingAppointments.isEmpty) {
      //     return const SizedBox.shrink();
      //   }
      //   return FloatingAppointmentWidget(
      //     appointments: controller.upcomingAppointments,
      //   );
      // }),
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
              // Put Instant Consult first (main focus - doctor in seconds)
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.bolt_rounded,
                  title: 'Doctor in Sec',
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

  // Get outlined version of icons
  IconData get outlinedIcon {
    switch (type) {
      case _QuickActionType.hospitalAppointment:
        return Icons.calendar_today_outlined;
      case _QuickActionType.videoConsult:
        return Icons.videocam_outlined;
      case _QuickActionType.instantConsult:
        return Icons.bolt_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Special styling for instant consult (Doctor in Sec) - our main focus
    final isMainFocus = type == _QuickActionType.instantConsult;
    
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
                 preSelectedAppointmentType: AppointmentType.video,
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
                preSelectedAppointmentType: AppointmentType.clinic,
              ));
              break;
          }
        },
        highlightColor: Colors.white.withOpacity(0.1),
        splashColor: Colors.white.withOpacity(0.2),
        child: Stack(
          children: [
            Container(
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
                  // Enhanced shadow for main focus card
                  if (isMainFocus)
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                      spreadRadius: 2,
                    ),
                ],
                // Enhanced border for main focus
                border: isMainFocus 
                    ? Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      )
                    : null,
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Center content horizontally
                children: [
                  Icon(
                    outlinedIcon, // Use outlined icon
                    color: Colors.white,
                    size: isMainFocus ? 44 : 40, // Bigger icon for main focus
                  ),
                  const SizedBox(height: 12), // Fixed spacing instead of Spacer
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: isMainFocus ? 15 : 14, // Slightly bigger text for main focus
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                      height: 1.2,
                    ),
                    maxLines: 2,
                    textAlign: TextAlign.center, // Center-align text
                    overflow: TextOverflow.visible,
                  ),
                ],
              ),
            ),
            
            // Badge for main focus card
            if (isMainFocus)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.shade500,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Text(
                    'FAST',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}







