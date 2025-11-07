import 'dart:ui';

import 'package:get/get.dart';
import '../../care_discovery/ui/care_discovery_screen.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../../instant_consultation/ui/instant_consult_screen.dart';
import '../../consultation_pending/ui/pending_consultation_screen.dart';
import '../../payment/ui/payment_screen.dart';

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

  /// Start instant consultation flow
  /// Flow: InstantConsultScreen -> PendingConsultationScreen -> VideoCallScreen
  void startInstantConsultation() {
    Get.to(() => const InstantConsultScreen());
  }

  /// Start scheduled consultation flow
  /// Flow: CareDiscoveryScreen -> SpecialityDoctorsScreen -> PaymentScreen -> PendingConsultationScreen -> VideoCallScreen
  void startScheduledConsultation() {
    Get.to(() => const CareDiscoveryScreen(entry: 'Find Care'));
  }

  /// Navigate to speciality doctors screen (from CareDiscoveryScreen)
  void navigateToSpecialityDoctors(String category) {
    Get.to(() => SpecialityDoctorsScreen(category: category));
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

