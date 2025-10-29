import 'package:get/get.dart';
import 'app_routes.dart';

class AppNavigation {
  // Navigate to Landing
  static void toLanding() {
    Get.toNamed(AppRoutes.landing);
  }

  // Navigate to Onboarding
  static void toOnboarding() {
    Get.toNamed(AppRoutes.onboarding);
  }

  // Navigate to Doctors Search
  static void toDoctors() {
    Get.toNamed(AppRoutes.doctors);
  }

  // Navigate to Appointments
  static void toAppointments() {
    Get.toNamed(AppRoutes.appointments);
  }

  // Navigate to Appointment Detail
  static void toAppointmentDetail(String bookingId) {
    Get.toNamed(AppRoutes.appointmentDetail, arguments: bookingId);
  }

  // Navigate to Care Discovery
  static void toCareDiscovery({String entry = 'Find Care'}) {
    Get.toNamed(AppRoutes.careDiscovery, arguments: {'entry': entry});
  }

  // Navigate to Doctor Detail
  static void toDoctorDetail(String doctorId) {
    Get.toNamed(AppRoutes.doctorDetail, arguments: {'id': doctorId});
  }

  // Navigate to Consultation Confirmed
  static void toConsultationConfirmed({
    String? name,
    String? specialization,
    String? hospital,
    String? imageUrl,
    String? status,
  }) {
    Get.toNamed(
      AppRoutes.consultationConfirmed,
      arguments: {
        'name': name,
        'specialization': specialization,
        'hospital': hospital,
        'imageUrl': imageUrl,
        'status': status,
      },
    );
  }

  // Navigate to Family Members
  static void toFamilyMembers() {
    Get.toNamed(AppRoutes.familyMembers);
  }

  // Navigate and clear all previous routes
  static void offAllToLanding() {
    Get.offAllNamed(AppRoutes.landing);
  }

  static void offAllToOnboarding() {
    Get.offAllNamed(AppRoutes.onboarding);
  }

  // Navigate and replace current route
  static void offToLanding() {
    Get.offNamed(AppRoutes.landing);
  }

  static void offToOnboarding() {
    Get.offNamed(AppRoutes.onboarding);
  }

  // Go back
  static void back() {
    Get.back();
  }

  // Go back with result
  static void backWithResult(dynamic result) {
    Get.back(result: result);
  }

  // // Check if can go back
  // static bool canPop() {
  //   return Get.canPop();
  // }
}
