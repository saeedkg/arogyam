import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../_shared/routing/routing.dart';
import '../../_shared/consultation/consultation_type.dart';
import '../../_shared/ui/app_colors.dart';
import '../controller/care_discovery_controller.dart';
import 'components/specialization_grid.dart';
import 'search_screen.dart';

class CareDiscoveryScreen extends StatefulWidget {
  final String entry;
  final AppointmentType? preSelectedAppointmentType;
  
  const CareDiscoveryScreen({
    super.key,
    required this.entry,
    this.preSelectedAppointmentType,
  });

  @override
  State<CareDiscoveryScreen> createState() => _CareDiscoveryScreenState();
}

class _CareDiscoveryScreenState extends State<CareDiscoveryScreen> {
  @override
  Widget build(BuildContext context) {
    final c = Get.put(CareDiscoveryController());
    
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.arrow_back_ios_rounded, 
              size: 18,
              color: Colors.black87,
            ),
          ),
          onPressed: Get.back,
        ),
        title: Text(
          widget.entry, 
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: AppColors.backgroundLight,
        surfaceTintColor: Colors.transparent,
      ),
      body: Obx(() {
        if (c.isLoading.value) {
          return Center(
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryGreen),
                    strokeWidth: 3,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Loading specializations...',
                    style: TextStyle(
                      color: AppColors.grey600,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        return SingleChildScrollView(
          child: Column(
            children: [
              // Compact Search Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: GestureDetector(
                  onTap: () => Get.to(() => SearchScreen(
                    preSelectedAppointmentType: widget.preSelectedAppointmentType,
                  )),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: AppColors.grey50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.grey200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.search_rounded,
                          color: AppColors.grey600,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Search doctor or speciality',
                            style: TextStyle(
                              color: AppColors.grey500,
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppColors.grey400,
                          size: 16,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Specializations Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: SpecializationGrid(
                  specializations: c.specializations,
                  preSelectedAppointmentType: widget.preSelectedAppointmentType,
                ),
              ),
              
              const SizedBox(height: 32),
            ],
          ),
        );
      }),
    );
  }
}
