import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../family_member/ui/family_member_screen.dart';
import 'app_routes.dart';
import '../../auth/request_otp_screen.dart';
import '../../booking/ui/doctor_booking_screen.dart';
import '../../doctor_detail/ui/doctor_detail_bottom_sheet.dart';

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
    Get.bottomSheet(
      DoctorDetailBottomSheet(doctorId: doctorId),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
    );
  }

  // Navigate to Consultation Confirmed


  // Navigate to Family Members
  static Future<dynamic> toFamilyMembers() {
    return Get.bottomSheet(
      const FamilyMembersBottomSheet(),
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFFFFFF),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    );
  }

  // Navigate to Instant Consult
  static void toInstantConsult() {
    Get.toNamed(AppRoutes.instantConsult);
  }

  // Navigate to Health Records
  static void toHealthRecords() {
    Get.toNamed(AppRoutes.healthRecords);
  }

  // Navigate to Doctor Booking
  static void toDoctorBooking(String doctorId) {
    Get.toNamed(AppRoutes.doctorBooking, arguments: {'id': doctorId});
  }

  // Navigate and clear all previous routes
  static void offAllToLanding() {
    Get.offAllNamed(AppRoutes.landing);
  }

  static void offAllToOnboarding() {
    Get.offAllNamed(AppRoutes.onboarding);
  }

  static void offAllToRequestOtpScreen() {
    Get.offAll(() => const RequestOtpScreen());
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
