import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/routing/routing.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../controller/care_discovery_controller.dart';
import 'components/specialization_grid.dart';

class CareDiscoveryScreen extends StatelessWidget {
  final String entry;
  final AppointmentType? preSelectedAppointmentType;
  
  const CareDiscoveryScreen({
    super.key,
    required this.entry,
    this.preSelectedAppointmentType,
  });

  @override
  Widget build(BuildContext context) {
    final c = Get.put(CareDiscoveryController());
    
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded, size: 20),
          onPressed: Get.back,
        ),
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
              SpecializationGrid(
                specializations: c.specializations,
                preSelectedAppointmentType: preSelectedAppointmentType,
              ),
            ],
          ),
        );
      }),
    );
  }
}
