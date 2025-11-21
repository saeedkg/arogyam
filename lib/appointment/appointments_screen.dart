import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../_shared/routing/routing.dart';
import '../_shared/patient/current_patient_controller.dart';
import '../_shared/consultation/consultation_flow_manager.dart';
import '../_shared/utils/date_time_formatter.dart';
import 'controler/appointments_controller.dart';
import 'components/appontment_card.dart';
import 'components/patient_card.dart';
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

  @override
  void initState() {
    super.initState();
    c = Get.put(AppointmentsController());
    currentPatientController = Get.put(CurrentPatientController());
    _scrollController = ScrollController();
    
    // Set initial patient ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.setPatientId(currentPatientController.current.value?.id);
    });
    
    // Add scroll listener for pagination
    _scrollController.addListener(_onScroll);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Appointments',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      ),
      body: Obx(() => _buildAppointmentsList()),
    );
  }

  Widget _buildAppointmentsList() {
    // Loading state - first load
    if (c.isLoading.value && c.appointments.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
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
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state
    if (c.appointments.isEmpty) {
      return RefreshIndicator(
        onRefresh: c.refreshAppointments,
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
                    Icons.calendar_today_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No appointments found',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
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
      onRefresh: c.refreshAppointments,
      child: ListView.builder(
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
                child: Center(child: CircularProgressIndicator()),
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
            onView: () {
              // If status is confirmed and type is instant, go to pending consultation screen
              if (appointment.status == AppointmentStatus.confirmed ||
                  appointment.status == AppointmentStatus.pending) {
                ConsultationFlowManager.instance
                    .navigateToPendingConsultation(appointment.id.toString());
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
            currentPatientController.refreshFromPrefs();
            
            // Reload appointments with the selected patient ID
            c.setPatientId(selectedPatientId as String);
          }
        },
      );
    });
  }


}

class _Tabs extends StatelessWidget {
  final int index;
  final ValueChanged<int> onChanged;

  const _Tabs({required this.index, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Row(
        children: [
          _chip('Upcoming', 0),
          const SizedBox(width: 8),
          _chip('Completed', 1),
          const SizedBox(width: 8),
          _chip('Canceled', 2),
        ],
      ),
    );
  }

  Widget _chip(String label, int i) {
    final active = index == i;
    return ChoiceChip(
      label: Text(label),
      selected: active,
      onSelected: (_) => onChanged(i),
      selectedColor: Colors.black87,
      labelStyle: TextStyle(
        color: active ? Colors.white : Colors.black87,
        fontWeight: FontWeight.w600,
      ),
      shape: const StadiumBorder(
        side: BorderSide(color: Colors.black12),
      ),
    );
  }
}
