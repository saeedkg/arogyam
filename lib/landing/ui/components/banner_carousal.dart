import 'package:carousel_slider/carousel_options.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../controller/home_controller.dart';
import '../../entities/banner_item.dart';

class BannerCarousel extends StatelessWidget {
  final List<BannerItem> banners;
  const BannerCarousel({required this.banners});

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