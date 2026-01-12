import 'dart:ui';

import 'package:get/get.dart';
import '../../care_discovery/ui/care_discovery_screen.dart';
import '../../instant_consultation/ui/instant_consult_screen.dart';
import '../../consultation_pending/ui/pending_consultation_screen.dart';
import 'consultation_type.dart';

enum ConsultationType {
  instant,
  scheduled,
}

class ConsultationFlowManager {
  static ConsultationFlowManager? _instance;
  static ConsultationFlowManager get instance {
    _instance ??= ConsultationFlowManager._();
    return _instance!;
  }

  ConsultationFlowManager._();

  // Store pre-selected appointment type from QuickActions
  AppointmentType? _preSelectedAppointmentType;

  /// Start instant consultation flow
  /// Flow: InstantConsultScreen -> PendingConsultationScreen -> VideoCallScreen
  void startInstantConsultation() {
    Get.to(() => const InstantConsultScreen());
  }

  /// Start scheduled consultation flow using direct navigation
  /// Flow: CareDiscoveryScreen -> ConsultationTypeSelection -> SpecialityDoctorsScreen -> DoctorBookingScreen -> PendingConsultationScreen
  /// Optional appointmentType parameter to skip the selection screen
  void startScheduledConsultation({AppointmentType? appointmentType}) {
    _preSelectedAppointmentType = appointmentType;
    
    // Direct navigation to CareDiscoveryScreen
    Get.to(() => CareDiscoveryScreen(
      entry: appointmentType != null ? 'Quick Action' : 'Find Care',
      preSelectedAppointmentType: appointmentType,
    ));
  }

  /// Clear the pre-selected appointment type
  void clearAppointmentType() {
    _preSelectedAppointmentType = null;
  }

  /// Navigate to pending consultation screen (after booking/payment)
  void navigateToPendingConsultation(String appointmentId) {
    Get.to(() => PendingConsultationScreen(appointmentId: appointmentId));
  }
}

