import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../landing/controller/home_controller.dart';
import '../landing/ui/components/dasbboard_category.dart';

class CareDiscoveryScreen extends StatelessWidget {
  final String entry;
  const CareDiscoveryScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(entry, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              decoration: InputDecoration(
                hintText: 'Search doctor or speciality',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              ),
              onSubmitted: (q) => Get.toNamed('/doctors', arguments: {'query': q}),
            ),
            const SizedBox(height: 16),
            GetBuilder<HomeController>(
              builder: (controller) => CategoriesGrid(categories: controller.categories),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}