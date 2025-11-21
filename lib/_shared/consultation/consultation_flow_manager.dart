import 'dart:ui';

import 'package:get/get.dart';
import '../../care_discovery/ui/care_discovery_screen.dart';
import '../../care_discovery/ui/consultation_type_selection_screen.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../../instant_consultation/ui/instant_consult_screen.dart';
import '../../consultation_pending/ui/pending_consultation_screen.dart';
import '../../payment/ui/payment_screen.dart';
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

  /// Start scheduled consultation flow
  /// Flow: CareDiscoveryScreen -> SpecialityDoctorsScreen -> PaymentScreen -> PendingConsultationScreen -> VideoCallScreen
  /// Optional appointmentType parameter to skip the selection screen
  void startScheduledConsultation({AppointmentType? appointmentType}) {
    _preSelectedAppointmentType = appointmentType;
    Get.to(() => CareDiscoveryScreen(
      entry: 'Find Care',
      preSelectedAppointmentType: appointmentType,
    ));
  }

  /// Clear the pre-selected appointment type
  void clearAppointmentType() {
    _preSelectedAppointmentType = null;
  }

  /// Navigate from CareDiscovery to either selection screen or doctors screen
  /// If appointmentType is pre-selected (from QuickAction), skip selection screen
  void navigateFromCareDiscovery({
    required String speciality,
    AppointmentType? preSelectedType,
  }) {
    if (preSelectedType != null) {
      // Skip selection screen, go directly to doctors
      navigateToSpecialityDoctors(
        category: speciality,
        appointmentType: preSelectedType,
      );
    } else {
      // Show consultation type selection screen
      Get.to(() => ConsultationTypeSelectionScreen(speciality: speciality));
    }
  }

  /// Navigate to speciality doctors screen (from CareDiscoveryScreen)
  /// Optional appointmentType parameter for filtering
  void navigateToSpecialityDoctors({
    required String category,
    AppointmentType? appointmentType,
  }) {
    Get.to(() => SpecialityDoctorsScreen(
      category: category,
      appointmentType: appointmentType,
    ));
  }

  /// Navigate from selection screen to doctors with selected appointment type
  void navigateWithAppointmentType({
    required String speciality,
    required AppointmentType appointmentType,
  }) {
    navigateToSpecialityDoctors(
      category: speciality,
      appointmentType: appointmentType,
    );
  }

  /// Navigate to payment screen (from SpecialityDoctorsScreen after booking)
  void navigateToPayment({
    required double consultationFee,
    required String appointmentId,
    required VoidCallback onPaymentSuccess,
  }) {
    Get.to(() => PaymentScreen(
      consultationFee: consultationFee,
      appointmentId: appointmentId,
      onPaymentSuccess: onPaymentSuccess,
    ));
  }

  /// Navigate to pending consultation screen (after booking/payment)
  void navigateToPendingConsultation(String appointmentId) {
    Get.to(() => PendingConsultationScreen(appointmentId: appointmentId));
  }

  /// Complete flow: After payment success, go to pending consultation
  void handlePaymentSuccess(String appointmentId) {
    Get.back(); // Close payment screen
    navigateToPendingConsultation(appointmentId);
  }
}

