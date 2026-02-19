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
              // Custom AppBar with gradient and patient card
              Container(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
                child: Column(
                  children: [
                    // Top row with title and refresh button
                    Row(
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
                    const SizedBox(height: 16),
                    // Patient card and filter tabs in same row
                    if (!_isGuestMode) _buildPatientCardWithFilters(),
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
        itemCount: c.appointments.length + 1, // +1 for loading indicator
        itemBuilder: (context, index) {
          // Loading indicator at bottom
          if (index == c.appointments.length) {
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
          final appointment = c.appointments[index];
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

  Widget _buildPatientCardWithFilters() {
    return Obx(() {
      final p = currentPatientController.current.value;
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 2),
        child: Row(
          children: [
            // Patient card - slightly more space, transparent background
            Expanded(
              flex: 5,
              child: Material(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () async {
                    final selectedPatientId = await AppNavigation.toFamilyMembers();
                    if (selectedPatientId != null) {
                      await currentPatientController.refreshFromPrefs();
                      final newPatientId = currentPatientController.current.value?.id;
                      if (newPatientId != null) {
                        c.setPatientId(newPatientId);
                      }
                    }
                  },
                  borderRadius: BorderRadius.circular(16),
                  splashColor: Colors.white.withOpacity(0.1),
                  highlightColor: Colors.white.withOpacity(0.05),
                  child: Container(
                    decoration: BoxDecoration(
                      // Transparent background with gradient border effect
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withOpacity(0.2),
                          Colors.white.withOpacity(0.1),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                          spreadRadius: 0,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        // Compact avatar with white background
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.8),
                              width: 2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.network(
                              'https://i.pravatar.cc/150?img=65',
                              width: 24,
                              height: 24,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) => Container(
                                color: AppColors.primaryGreen.withOpacity(0.1),
                                child: Icon(
                                  Icons.person_rounded,
                                  color: AppColors.primaryGreen,
                                  size: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                p?.name ?? 'Select Patient',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  letterSpacing: -0.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 1),
                              if (p?.dateOfBirth != null || p?.id != null)
                                Text(
                                  '${p?.dateOfBirth ?? ''} ${(p?.dateOfBirth != null && p?.id != null) ? '•' : ''} ${p?.id != null ? 'ID: ${p!.id}' : ''}',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white.withOpacity(0.8),
                                    letterSpacing: 0.1,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 4),
                        // Compact switch indicator
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Filter tabs - balanced space and reduced height
            Expanded(
              flex: 7,
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.2),
                      Colors.white.withOpacity(0.1),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.3),
                    width: 1.5,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(
                      child: _buildCompactFilterTab(
                        'Active',
                        AppointmentFilter.upcoming,
                        Icons.schedule_rounded,
                      ),
                    ),
                    Expanded(
                      child: _buildCompactFilterTab(
                        'Past',
                        AppointmentFilter.past,
                        Icons.history_rounded,
                      ),
                    ),
                    Expanded(
                      child: _buildCompactFilterTab(
                        'All',
                        AppointmentFilter.all,
                        Icons.list_rounded,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildCompactFilterTab(String title, AppointmentFilter filter, IconData icon) {
    final isSelected = c.selectedFilter.value == filter;
    
    return GestureDetector(
      onTap: () => c.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 14,
              color: isSelected 
                  ? AppColors.primaryGreen 
                  : Colors.white.withOpacity(0.9),
            ),
            const SizedBox(height: 2),
            Text(
              title,
              style: TextStyle(
                fontSize: 9,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected 
                    ? AppColors.primaryGreen 
                    : Colors.white.withOpacity(0.95),
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderPatientCard() {
    return Obx(() {
      final p = currentPatientController.current.value;
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () async {
            final selectedPatientId = await AppNavigation.toFamilyMembers();
            if (selectedPatientId != null) {
              await currentPatientController.refreshFromPrefs();
              final newPatientId = currentPatientController.current.value?.id;
              if (newPatientId != null) {
                c.setPatientId(newPatientId);
              }
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                // Compact avatar
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(color: Colors.white.withOpacity(0.3), width: 1.5),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      'https://i.pravatar.cc/150?img=65',
                      width: 32,
                      height: 32,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: AppColors.grey50,
                        child: Icon(
                          Icons.person_rounded,
                          color: AppColors.teal,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        p?.name ?? 'Patient',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${p?.dateOfBirth ?? ''} • ID: ${p?.id ?? ''}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 10,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Dropdown arrow
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildFilterTabs() {
    return Obx(() {
      return Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
        ),
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            Expanded(
              child: _buildFilterTab(
                'Active',
                AppointmentFilter.upcoming,
                Icons.schedule_rounded,
              ),
            ),
            Expanded(
              child: _buildFilterTab(
                'Past',
                AppointmentFilter.past,
                Icons.history_rounded,
              ),
            ),
            Expanded(
              child: _buildFilterTab(
                'All',
                AppointmentFilter.all,
                Icons.list_rounded,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterTab(String title, AppointmentFilter filter, IconData icon) {
    final isSelected = c.selectedFilter.value == filter;
    
    return GestureDetector(
      onTap: () => c.setFilter(filter),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected 
                  ? AppColors.primaryGreen 
                  : Colors.white.withOpacity(0.8),
            ),
            const SizedBox(width: 6),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected 
                    ? AppColors.primaryGreen 
                    : Colors.white.withOpacity(0.9),
                letterSpacing: 0.2,
              ),
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


