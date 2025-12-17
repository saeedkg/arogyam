import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../../_shared/ui/app_text.dart';
import '../../../_shared/ui/app_colors.dart';
import '../components/banner_carousal.dart';
import '../components/dasbboard_category.dart';
import '../components/dashboard_app_bar.dart';
import '../components/dashboard_quick_action_view.dart' show QuickActions;
import '../components/dashboard_serach_view.dart';
import '../components/top_doctors_view.dart';
import '../components/upcoming_appointments_section.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return SafeArea(
      child: RefreshIndicator(
        onRefresh: controller.loadAll,
        color: AppColors.primaryGreen,
        backgroundColor: Colors.white,
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            DashboardAppBar(),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
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
                      const SearchSection(),
                      const SizedBox(height: 16),
                      
                      // Upcoming Appointments Section
                      UpcomingAppointmentsSection(
                        appointments: controller.upcomingAppointments,
                      ),
                      if (controller.upcomingAppointments.isNotEmpty)
                        const SizedBox(height: 16),
                      
                      QuickActions(),
                      const SizedBox(height: 16),
                      BannerCarousel(banners: controller.banners),
                      const SizedBox(height: 16),
                      const SizedBox(height: 8),
                      CategoriesGrid(categories: controller.categories),
                      const SizedBox(height: 16),
                      _SectionHeader(title: 'Top doctors'),
                      const SizedBox(height: 8),
                      TopDoctors(doctors: controller.topDoctors),
                      const SizedBox(height: 20), // Bottom padding
                    ],
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppText.titleLarge(title, maxLines: 2, overflow: TextOverflow.ellipsis),
        const Spacer(),
        TextButton(onPressed: () {}, child: const Text('See all')),
      ],
    );
  }
}





