import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import '../_shared/routing/routing.dart';
import '../_shared/patient/current_patient_controller.dart';
import '../_shared/patient/current_patient.dart';
import '../_shared/ui/app_colors.dart';
import '../_shared/utils/date_time_formatter.dart';
import '../_shared/components/guest_mode_handler.dart';
import '../auth/user_management/service/auth_token_provider.dart';
import '../consultation_pending/ui/pending_consultation_screen.dart';
import 'controler/appointments_controller.dart';
import 'components/appontment_card.dart';
import 'components/patient_card.dart';
import 'components/appointment_empty_state_card.dart';
import 'entities/appointment_status.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  late AppointmentsController c;
  late CurrentPatientController currentPatientController;
  late ScrollController _scrollController;
  bool _isGuestMode = false;
  bool _showGuestBanner = true;

  @override
  void initState() {
    super.initState();
    c = Get.put(AppointmentsController());
    currentPatientController = Get.put(CurrentPatientController());
    _scrollController = ScrollController();
    
    // Check if user is in guest mode
    _checkGuestMode();
    
    // Wait for current patient to load, then set patient ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializePatientAndAppointments();
    });
    
    // Listen to current patient changes
    ever(currentPatientController.current, (CurrentPatient? patient) {
      if (patient != null && patient.id != c.currentPatientId) {
        c.setPatientId(patient.id);
      }
    });
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
  }

  Future<void> _checkGuestMode() async {
    final authTokenProvider = AuthTokenProvider();
    final token = await authTokenProvider.getToken();
    setState(() {
      _isGuestMode = token == null;
    });
  }

  Future<void> _initializePatientAndAppointments() async {
    // Ensure current patient is loaded from preferences
    await currentPatientController.refreshFromPrefs();
    
    // Set patient ID and load appointments
    final currentPatientId = currentPatientController.current.value?.id;
    if (currentPatientId != null) {
      c.setPatientId(currentPatientId);
    } else {
      // If no current patient, still try to load appointments
      c.fetchInitialAppointments();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      c.fetchMoreAppointments();
    }
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
              AppColors.primaryGreen,// Slightly darker green
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
                        'Appointments',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
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
                        onPressed: () => c.refreshAppointments(),
                        tooltip: 'Refresh',
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
                    child: Obx(() => _buildAppointmentsList()),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentsList() {
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
              title: 'Sign In to View Appointments',
              description: 'Access your appointment history, upcoming consultations, and manage your healthcare schedule.',
              featureName: 'appointments',
              icon: Icons.calendar_today_rounded,
            ),
          ),
        ],
      );
    }

    // Loading state - first load
    if (c.isLoading.value && c.appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Color(0xFF22C58B), // AppColors.primaryGreen
              strokeWidth: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Loading appointments...',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    // Error state - no data
    if (c.errorMessage.value.isNotEmpty && c.appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: c.refreshAppointments,
        color: const Color(0xFF22C58B), // AppColors.primaryGreen
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(20),
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    c.errorMessage.value.toLowerCase().contains('internet')
                        ? Icons.wifi_off
                        : Icons.error_outline,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    c.errorMessage.value,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => c.fetchInitialAppointments(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C58B),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Empty state
    if (c.appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: c.refreshAppointments,
        color: const Color(0xFF22C58B), // AppColors.primaryGreen
        backgroundColor: Colors.white,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _buildPatientCard(),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            const AppointmentEmptyStateCard(),
          ],
        ),
      );
    }

    // List with data
    return RefreshIndicator(
      onRefresh: c.refreshAppointments,
      color: const Color(0xFF22C58B), // AppColors.primaryGreen
      backgroundColor: Colors.white,
      strokeWidth: 3.0,
      displacement: 40.0,
      child: ListView.builder(
        physics: const AlwaysScrollableScrollPhysics(),
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: c.appointments.length + 2, // +2 for patient card and loading indicator
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

          // Loading indicator at bottom
          if (index == c.appointments.length + 1) {
            if (c.isLoading.value && !c.api.didReachListEnd) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF22C58B), // AppColors.primaryGreen
                    strokeWidth: 3,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          // Appointment cards
          final appointment = c.appointments[index - 1];
          return AppointmentCard(
            id: appointment.id.toString(),
            imageUrl: appointment.doctorImage,
            name: appointment.doctorName,
            specialization: appointment.specialization,
            date: (DateTimeFormatter.formatDateShort(appointment.scheduledAt)),
            time: (DateTimeFormatter.formatTime(appointment.scheduledAt)),
            status: appointment.status,
            type: appointment.type,
            // Enhanced fields
            consultationFee: appointment.consultationFee,
            hasPrescription: appointment.hasPrescription,
            isFollowUpEligible: appointment.isFollowUpEligible,
            consultationStatus: appointment.consultationStatus,
            doctorExperience: appointment.doctorExperience,
            doctorQualifications: appointment.doctorQualifications,
            canJoinNow: appointment.canJoinNow,
            onView: () {
              // Handle different appointment statuses
              if (appointment.status == AppointmentStatus.confirmed ||
                  appointment.status == AppointmentStatus.pending ||
                  appointment.status == AppointmentStatus.inProgress) {
                // Go to pending consultation screen for active appointments
                Get.to(() => PendingConsultationScreen(appointmentId: appointment.id.toString()));
              } else if (appointment.status == AppointmentStatus.expired) {
                // Show expired message or go to detail screen
                AppNavigation.toAppointmentDetail(appointment.id.toString());
              } else {
                // Otherwise, go to appointment detail screen
                AppNavigation.toAppointmentDetail(appointment.id.toString());
              }
            },
          );
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
          print("---");
          print(selectedPatientId);
          
          // If a patient was selected, reload appointments
          if (selectedPatientId != null) {
            // Refresh current patient from prefs
            await currentPatientController.refreshFromPrefs();
            
            // The listener will automatically reload appointments when current patient changes
            // But we can also explicitly reload to ensure it happens immediately
            final newPatientId = currentPatientController.current.value?.id;
            if (newPatientId != null) {
              c.setPatientId(newPatientId);
            }
          }
        },
      );
    });
  }


}


