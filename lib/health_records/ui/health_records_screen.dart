import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../_shared/ui/app_colors.dart';
import '../controller/health_records_controller.dart';
import 'componets/health_record_card.dart';
import 'componets/upload_health_record_dailog.dart';

class HealthRecordsScreen extends StatelessWidget {
  const HealthRecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(HealthRecordsController());
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
              Get.find<HealthRecordsController>().refreshRecords();
            },
          ),
        ],
      ),
      body: GetBuilder<HealthRecordsController>(
        builder: (controller) => Obx(() {
          if (controller.isLoading.value && controller.healthRecords.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          
          return controller.healthRecords.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: () => controller.refreshRecords(),
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: controller.healthRecords.length,
                    itemBuilder: (context, index) {
                      final record = controller.healthRecords[index];
                      return HealthRecordCard(record: record);
                    },
                  ),
                );
        }),
      ),
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.medical_services_outlined,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 24),
          Text(
            'No Health Records',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
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
    );
  }

  void _showUploadDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => UploadRecordDialog(),
    );
  }
}




