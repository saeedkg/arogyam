import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/routing/routing.dart';
import '../controller/care_discovery_controller.dart';
import 'components/specialization_grid.dart';

class CareDiscoveryScreen extends StatelessWidget {
  final String entry;
  const CareDiscoveryScreen({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CareDiscoveryController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text(entry, style: const TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        
        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search doctor or speciality',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
                onSubmitted: (q) => AppNavigation.toDoctors(),
              ),
              const SizedBox(height: 20),
              SpecializationGrid(specializations: c.specializations),
            ],
          ),
        );
      }),
    );
  }
}
