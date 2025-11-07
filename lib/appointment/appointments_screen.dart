import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../_shared/routing/routing.dart';
import '../_shared/patient/current_patient_controller.dart';
import '../_shared/consultation/consultation_flow_manager.dart';
import 'controler/appointments_controller.dart';
import 'components/appontment_card.dart';
import 'components/patient_card.dart';
import 'entities/appointment_status.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.put(AppointmentsController());
    final currentPatientController = Get.put(CurrentPatientController());

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
      body: Obx(
            () => c.isLoading.value
            ? const Center(child: CircularProgressIndicator())
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Obx(() {
              final p = currentPatientController.current.value;
              return PatientCard(
                name: p?.name ?? 'Patient',
                dob: p?.dateOfBirth ?? '',
                id: p?.id ?? '',
                imageUrl: 'https://i.pravatar.cc/150?img=65',
                onChange: () async {
                  // Open family members; after close, refresh current patient from prefs
                  AppNavigation.toFamilyMembers();
                  // Give time for bottom sheet to close and selection to be saved
                  Future.delayed(const Duration(milliseconds: 300), () {
                    currentPatientController.refreshFromPrefs();
                  });
                },
              );
            }),
            const SizedBox(height: 16),
            ...c.appointments.map(
                  (b) => AppointmentCard(
                id: b.id.toString(),
                imageUrl: b.doctorImage,
                name: b.doctorName,
                specialization: b.specialization,
                date: _formatDate(b.scheduledAt),
                time: _formatTime(b.scheduledAt),
                status: b.status,
                type: b.type,
                onView: () {
                  // If status is confirmed and type is instant, go to pending consultation screen
                  if (b.status == AppointmentStatus.confirmed && b.type == 'instant') {
                    ConsultationFlowManager.instance.navigateToPendingConsultation(b.id.toString());
                  } else {
                    // Otherwise, go to appointment detail screen
                    AppNavigation.toAppointmentDetail(b.id.toString());
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${_month(dt.month)} ${dt.day}, ${dt.year}';
  }

  String _formatTime(DateTime dt) {
    final hour = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
    final amPm = dt.hour >= 12 ? 'PM' : 'AM';
    return '${_pad(hour)}:${_pad(dt.minute)} $amPm';
  }

  String _pad(int n) => n.toString().padLeft(2, '0');

  String _month(int m) => const [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ][m - 1];
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
