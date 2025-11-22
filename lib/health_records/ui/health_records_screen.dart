import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../_shared/ui/app_colors.dart';
import '../../_shared/patient/current_patient_controller.dart';
import '../../_shared/routing/routing.dart';
import '../../appointment/components/patient_card.dart';
import '../controller/health_records_controller.dart';
import 'componets/health_record_card.dart';
import 'componets/upload_health_record_dailog.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key});

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  late HealthRecordsController controller;
  late CurrentPatientController currentPatientController;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HealthRecordsController());
    currentPatientController = Get.put(CurrentPatientController());
    
    // Set initial patient ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setPatientId(currentPatientController.current.value?.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Health Records',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              controller.refreshRecords();
            },
          ),
        ],
      ),
      body: Obx(() => _buildRecordsList()),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showUploadDialog(context),
        backgroundColor: AppColors.primaryGreen,
        icon: const Icon(Icons.upload_file_rounded,color: Colors.white,),
        label: const Text(
          'Add Record',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildRecordsList() {
    // Loading state - first load
    if (controller.isLoading.value && controller.healthRecords.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading health records...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (controller.healthRecords.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshRecords,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPatientCard(),
            const SizedBox(height: 32),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.medical_services_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No Health Records',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload your medical documents here',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // List with data
    return RefreshIndicator(
      onRefresh: controller.refreshRecords,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: controller.healthRecords.length + 1, // +1 for patient card
        itemBuilder: (context, index) {
          // Patient card at top
          if (index == 0) {
            return Column(
              children: [
                _buildPatientCard(),
                const SizedBox(height: 16),
              ],
            );
          }

          // Health record cards
          final record = controller.healthRecords[index - 1];
          return HealthRecordCard(record: record);
        },
      ),
    );
  }

  Widget _buildPatientCard() {
    return Obx(() {
      final p = currentPatientController.current.value;
      return PatientCard(
        name: p?.name ?? 'Patient',
        dob: p?.dateOfBirth ?? '',
        id: p?.id ?? '',
        imageUrl: 'https://i.pravatar.cc/150?img=65',
        onChange: () async {
          // Open family members and wait for result (patient ID)
          final selectedPatientId = await AppNavigation.toFamilyMembers();
          
          // If a patient was selected, reload health records
          if (selectedPatientId != null) {
            // Refresh current patient from prefs
            currentPatientController.refreshFromPrefs();
            
            // Reload health records with the selected patient ID
            controller.setPatientId(selectedPatientId as String);
          }
        },
      );
    });
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UploadRecordDialog(),
    );
  }
}




