import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
import '../../../_shared/ui/app_text.dart';
import '../../entities/appointment.dart';
import '../../entities/banner_item.dart';
import '../../entities/category_item.dart';
import '../../entities/doctor.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    return SafeArea(
      child: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            title: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 20),
                const SizedBox(width: 6),
                Text(
                  'Bengaluru',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                IconButton(onPressed: () {}, icon: const Icon(Icons.notifications_outlined))
              ],
            ),
            centerTitle: false,
          ),
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
                    const _SearchSection(),
                    const SizedBox(height: 16),
                    _NextAppointmentCard(appointment: controller.nextAppointment.value),
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Quick actions'),
                    const SizedBox(height: 8),
                    _QuickActions(),
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Highlights'),
                    const SizedBox(height: 8),
                    _BannerCarousel(banners: controller.banners),
                    const SizedBox(height: 16),
                  //  _SectionHeader(title: 'Categories'),
                    const SizedBox(height: 8),
                    _CategoriesGrid(categories: controller.categories),
                    const SizedBox(height: 16),
                    _SectionHeader(title: 'Top doctors'),
                    const SizedBox(height: 8),
                    _TopDoctors(doctors: controller.topDoctors),
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

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: 'Search doctors or specialities',
        prefixIcon: const Icon(Icons.search),
        filled: true,
        fillColor: Colors.grey.shade100,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _NextAppointmentCard extends StatelessWidget {
  final Appointment? appointment;
  const _NextAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    if (appointment == null) return const SizedBox.shrink();
    final a = appointment!;
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(12),
            child: const Icon(Icons.video_call, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText.label('Next Appointment', color: Colors.blue.shade700),
                const SizedBox(height: 6),
                AppText.titleMedium(a.doctorName),
                AppText.bodySmall(a.specialization, color: Colors.black54),
                const SizedBox(height: 8),
                AppText.bodySmall('${a.startTime.day}/${a.startTime.month}/${a.startTime.year}  •  ${a.startTime.hour.toString().padLeft(2, '0')}:${a.startTime.minute.toString().padLeft(2, '0')}', color: Colors.black87),
              ],
            ),
          ),
          const SizedBox(width: 8),
          FilledButton(onPressed: () {}, child: const Text('Details')),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: _QuickActionCard(icon: Icons.local_hospital, title: 'Hospital\nAppointment', color: Colors.teal)),
        const SizedBox(width: 12),
        Expanded(child: _QuickActionCard(icon: Icons.video_call, title: 'Video\nConsult', color: Colors.deepPurple)),
        const SizedBox(width: 12),
        Expanded(child: _QuickActionCard(icon: Icons.flash_on, title: 'Consult\nNow', color: Colors.orange)),
      ],
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color color;
  const _QuickActionCard({required this.icon, required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 12),
          AppText.titleMedium(title,maxLines: 2),
        ],
      ),
    );
  }
}

class _BannerCarousel extends StatelessWidget {
  final List<BannerItem> banners;
  const _BannerCarousel({required this.banners});

  @override
  Widget build(BuildContext context) {
    if (banners.isEmpty) return const SizedBox.shrink();
    final controller = Get.find<HomeController>();
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CarouselSlider(
            options: CarouselOptions(
              height: 160,
              viewportFraction: 1.0,
              autoPlay: true,
              onPageChanged: (i, _) => controller.bannerIndex.value = i,
            ),
            items: banners
                .map((b) => Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(b.imageUrl, fit: BoxFit.cover),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.black.withOpacity(0.05), Colors.black.withOpacity(0.45)],
                            ),
                          ),
                        ),
                        Positioned(
                          left: 16,
                          bottom: 16,
                          right: 16,
                          child: Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
                        )
                      ],
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: 8),
        Obx(() => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                banners.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  height: 6,
                  width: controller.bannerIndex.value == i ? 18 : 6,
                  decoration: BoxDecoration(
                    color: controller.bannerIndex.value == i ? Colors.blue : Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            )),
      ],
    );
  }
}

class _CategoriesGrid extends StatelessWidget {
  final List<CategoryItem> categories;
  const _CategoriesGrid({required this.categories});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText.titleLarge('Categories'),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final c = categories[i];
            return Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 6))],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(c.icon, style: const TextStyle(fontSize: 26)),
                  const SizedBox(height: 8),
                  AppText.label(c.name),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class _TopDoctors extends StatelessWidget {
  final List<Doctor> doctors;
  const _TopDoctors({required this.doctors});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final d = doctors[i];
              return Container(
                width: 180,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 14, offset: const Offset(0, 8))
                ]),
                clipBehavior: Clip.antiAlias,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(d.imageUrl, height: 120, width: 180, fit: BoxFit.cover),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(d.specialization, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(children: [const Icon(Icons.star_rounded, size: 16, color: Colors.amber), const SizedBox(width: 4), Text(d.rating.toString())])
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        )
      ],
    );
  }
}


