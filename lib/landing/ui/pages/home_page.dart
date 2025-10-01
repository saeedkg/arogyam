import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/home_controller.dart';
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
                    _QuickActions(),
                    const SizedBox(height: 16),
                    _BannerCarousel(banners: controller.banners),
                    const SizedBox(height: 16),
                    _CategoriesGrid(categories: controller.categories),
                    const SizedBox(height: 16),
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
                Text('Next Appointment', style: Theme.of(context).textTheme.labelLarge?.copyWith(color: Colors.blue.shade700)),
                const SizedBox(height: 6),
                Text(a.doctorName, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(a.specialization, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black54)),
                const SizedBox(height: 8),
                Text(
                  '${a.startTime.day}/${a.startTime.month}/${a.startTime.year}  •  ${a.startTime.hour.toString().padLeft(2, '0')}:${a.startTime.minute.toString().padLeft(2, '0')}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.black87),
                ),
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
          Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
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
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: CarouselSlider(
        options: CarouselOptions(height: 160, viewportFraction: 1.0, autoPlay: true),
        items: banners
            .map((b) => Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(b.imageUrl, fit: BoxFit.cover),
                    Container(color: Colors.black26),
                    Positioned(
                      left: 16,
                      bottom: 16,
                      right: 16,
                      child: Text(b.title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                    )
                  ],
                ))
            .toList(),
      ),
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
        Text('Categories', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 1.1),
          itemCount: categories.length,
          itemBuilder: (context, i) {
            final c = categories[i];
            return Container(
              decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(16)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(c.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(height: 8),
                  Text(c.name, style: Theme.of(context).textTheme.labelLarge),
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
        Text('Top Doctors', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        SizedBox(
          height: 210,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: doctors.length,
            separatorBuilder: (_, __) => const SizedBox(width: 12),
            itemBuilder: (context, i) {
              final d = doctors[i];
              return Container(
                width: 160,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 12, offset: const Offset(0, 6))
                ]),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: const BorderRadius.only(topLeft: Radius.circular(16), topRight: Radius.circular(16)),
                      child: Image.network(d.imageUrl, height: 110, width: 160, fit: BoxFit.cover),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(d.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w700)),
                          const SizedBox(height: 4),
                          Text(d.specialization, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                          const SizedBox(height: 6),
                          Row(children: [const Icon(Icons.star, size: 16, color: Colors.amber), const SizedBox(width: 4), Text(d.rating.toString())])
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


