import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../../_shared/ui/app_text.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../care_discovery/ui/care_discovery_screen.dart';
import '../../../care_discovery/ui/search_screen.dart';
import '../../../instant_consultation/ui/instant_consult_screen.dart';
import '../components/banner_carousal.dart';
import '../components/dasbboard_category.dart';
import '../components/dashboard_app_bar.dart';
import '../components/dashboard_quick_action_view.dart' show QuickActions;
import '../components/dashboard_serach_view.dart';
import '../components/top_doctors_view.dart';
import '../components/upcoming_appointments_section.dart';
import '../all_categories_screen.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: controller.loadAll,
        color: Colors.white,
        backgroundColor: AppColors.primaryGreen,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            // Collapsible SliverAppBar with blue gradient
            SliverAppBar(
              expandedHeight: 320,
              floating: false,
              pinned: true,
              elevation: 0,
              backgroundColor: const Color(0xFF2E6BA8),
              centerTitle: false,
              titleSpacing: 20,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding: EdgeInsets.zero,
                title: LayoutBuilder(
                  builder: (context, constraints) {
                    // Calculate collapse ratio (0 = fully expanded, 1 = fully collapsed)
                    final double collapseRatio = (320 - constraints.maxHeight) / (320 - kToolbarHeight);
                    final bool isCollapsed = collapseRatio > 0.5;
                    
                    return AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: isCollapsed ? 1.0 : 0.0,
                      child: SafeArea(
                        child: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.only(left: 20, bottom: 16),
                          child: const Text(
                            'Arogyam',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF4A90E2),
                        Color(0xFF357ABD),
                        Color(0xFF2E6BA8),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with app name and notification
                          Row(
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Arogyam',
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const Text(
                                    'Doctor in minutes',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.location_on,
                                        size: 14,
                                        color: Colors.white70,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Current Location: New Delhi, India',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.white.withOpacity(0.8),
                                        ),
                                      ),
                                    ],
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
                                  onPressed: () {},
                                  icon: const Icon(
                                    Icons.notifications_outlined,
                                    color: Colors.white,
                                    size: 22,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Search bar
                          const SearchSection(),
                          const SizedBox(height: 24),
                          
                          // Circular quick actions
                          const QuickActions(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // No title here - handled in FlexibleSpaceBar
              title: null,
              leading: const SizedBox.shrink(), // Remove back button
              leadingWidth: 0,
            ),
            
            // Main content
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
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 24),
                    
                    // Original QuickActions (card style)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20),
                      child: _OriginalQuickActions(),
                    ),
                    const SizedBox(height: 24),
                    
                    // Welcome offers banner
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: BannerCarousel(banners: controller.banners),
                    ),
                    const SizedBox(height: 24),
                    
                    // Top Specialities
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _SectionHeader(
                            title: 'Top Specialities',
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
                          CategoriesGrid(categories: controller.categories),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Top doctors
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        children: [
                          _SectionHeader(title: 'Top doctors'),
                          const SizedBox(height: 16),
                          TopDoctors(doctors: controller.topDoctors),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100), // Extra bottom padding for floating widget
                  ],
                );
              }),
            ),
          ],
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
          ),
        ),
        const Spacer(),
        TextButton(
          onPressed: onSeeAllPressed ?? () {},
          child: const Text(
            'See all',
            style: TextStyle(
              color: AppColors.primaryBlue,
              fontWeight: FontWeight.w600,
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.local_hospital_rounded,
                  title: 'Hospital Appointment',
                  color: AppColors.successGreen,
                  gradient: LinearGradient(
                    colors: [AppColors.successGreen.withOpacity(0.1), AppColors.successGreen.withOpacity(0.05)],
                  ),
                  type: _QuickActionType.hospitalAppointment,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.videocam_rounded,
                  title: 'Video\nConsult',
                  color: AppColors.infoBlue,
                  gradient: LinearGradient(
                    colors: [AppColors.infoBlue.withOpacity(0.1), AppColors.infoBlue.withOpacity(0.05)],
                  ),
                  type: _QuickActionType.videoConsult,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _QuickActionCard(
                  icon: Icons.bolt_rounded,
                  title: 'Instant\nConsult',
                  color: AppColors.warningOrange,
                  gradient: LinearGradient(
                    colors: [AppColors.warningOrange.withOpacity(0.1), AppColors.warningOrange.withOpacity(0.05)],
                  ),
                  type: _QuickActionType.instantConsult,
                ),
              ),
            ],
          ),
        ],
      ),
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
        highlightColor: color.withOpacity(0.1),
        splashColor: color.withOpacity(0.2),
        child: Container(
          height: 140,
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.grey.shade100, width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: color.withOpacity(0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(10),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 40, // Fixed height for exactly 2 lines
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                    height: 1.2,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.visible,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}





