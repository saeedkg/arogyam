import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../../_shared/ui/app_text.dart';
import '../components/banner_carousal.dart';
import '../components/dasbboard_category.dart';
import '../components/dashboard_app_bar.dart';
import '../components/dashboard_quick_action_view.dart' show QuickActions;
import '../components/dashboard_serach_view.dart';
import '../components/top_doctors_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          DashboardAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(child: CircularProgressIndicator());
                }
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SearchSection(),
                    //const SizedBox(height: 16),
                    //_NextAppointmentCard(appointment: controller.nextAppointment.value),
                    const SizedBox(height: 16),
                   // _SectionHeader(title: 'Quick actions'),
                  //  const SizedBox(height: 8),
                    QuickActions(),
                    const SizedBox(height: 16),
                  //  _SectionHeader(title: 'Highlights'),
                  //  const SizedBox(height: 8),
                    BannerCarousel(banners: controller.banners),
                    const SizedBox(height: 16),
                  //  _SectionHeader(title: 'Categories'),
                    const SizedBox(height: 8),
                    CategoriesGrid(categories: controller.categories),
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Top doctors'),
                    const SizedBox(height: 8),
                    TopDoctors(doctors: controller.topDoctors),
                  ],
                );
              }),
            ),
          ),
        ],
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





