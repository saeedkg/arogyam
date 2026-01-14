import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../../_shared/ui/app_colors.dart';
import '../../_shared/patient/current_patient_controller.dart';
import '../../_shared/routing/routing.dart';
import '../../_shared/components/guest_mode_handler.dart';
import '../../auth/user_management/service/auth_token_provider.dart';
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
  bool _isGuestMode = false;
  bool _showGuestBanner = true;

  @override
  void initState() {
    super.initState();
    controller = Get.put(HealthRecordsController());
    currentPatientController = Get.put(CurrentPatientController());
    
    // Check if user is in guest mode
    _checkGuestMode();
    
    // Set initial patient ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.setPatientId(currentPatientController.current.value?.id);
    });
  }

  Future<void> _checkGuestMode() async {
    final authTokenProvider = AuthTokenProvider();
    final token = await authTokenProvider.getToken();
    setState(() {
      _isGuestMode = token == null;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Set transparent status bar
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
    );
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.teal,
              AppColors.teal.withOpacity(0.9),
              AppColors.primaryGreen,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom AppBar with gradient
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Row(
                  children: [
                    Expanded(
                      child: const Text(
                        'Health Records',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: IconButton(
                        icon: const Icon(
                          Icons.refresh_rounded,
                          size: 20,
                          color: Colors.white,
                        ),
                        onPressed: () {
                          controller.refreshRecords();
                        },
                        tooltip: 'Refresh Records',
                      ),
                    ),
                  ],
                ),
              ),
          
              // Main content with white background
              Expanded(
                child: Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(24),
                      topRight: Radius.circular(24),
                    ),
                    child: Obx(() => _buildRecordsList()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Obx(() {
        // Don't show floating button for guest users
        if (_isGuestMode) {
          return Container();
        }
        
        // Only show floating button when there are health records
        if (controller.healthRecords.isNotEmpty) {
          return Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primaryGreen.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: FloatingActionButton.extended(
              onPressed: () => _showUploadDialog(context),
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              icon: const Icon(Icons.add_rounded, size: 22),
              label: const Text(
                'Add Record',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          );
        }
        return Container(); // Hide floating button when no records
      }),
    );
  }

  Widget _buildRecordsList() {
    // Guest mode handling
    if (_isGuestMode) {
      return Column(
        children: [
          // Guest banner
          if (_showGuestBanner)
            GuestModeHandler.buildGuestBanner(
              onDismiss: () => setState(() => _showGuestBanner = false),
            ),
          
          // Guest empty state
          Expanded(
            child: GuestModeHandler.buildGuestEmptyState(
              title: 'Sign In to Access Health Records',
              description: 'Securely store and access your medical documents, lab reports, prescriptions, and health history.',
              featureName: 'health records',
              icon: Icons.folder_open_rounded,
            ),
          ),
        ],
      );
    }

    // Loading state - first load
    if (controller.isLoading.value && controller.healthRecords.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.primaryBlue.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.5,
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryBlue),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Loading Health Records',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please wait while we fetch your medical documents...',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Empty state - only show when not loading and no records
    if (!controller.isLoading.value && controller.healthRecords.isEmpty) {
      return RefreshIndicator(
        onRefresh: controller.refreshRecords,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildPatientCard(),
            const SizedBox(height: 40),
            _buildEmptyState(),
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

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.grey200, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Medical illustration
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppColors.primaryBlue.withValues(alpha: 0.1),
                    AppColors.primaryGreen.withValues(alpha: 0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                Icons.folder_open_rounded,
                size: 40,
                color: AppColors.primaryBlue,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Title
            const Text(
              'No Health Records Yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 12),
            
            // Description
            Text(
              'Keep your medical documents organized and accessible.\nUpload lab reports, prescriptions, and medical records.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey600,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 24),
            
            // Action button
            ElevatedButton.icon(
              onPressed: () => _showUploadDialog(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              icon: const Icon(Icons.upload_file_rounded, size: 20),
              label: const Text(
                'Upload First Record',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Help text
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.grey500,
                ),
                const SizedBox(width: 6),
                Text(
                  'Supported formats: PDF, JPG, PNG',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey500,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
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




