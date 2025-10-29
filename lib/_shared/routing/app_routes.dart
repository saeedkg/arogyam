import 'package:get/get.dart';
import '../../auth/request_otp_screen.dart';
import '../../landing/ui/landing_screen.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../find_doctor/search_doctors_screen.dart';
import '../../appointment/appointments_screen.dart';
import '../../appointment/appointment_detail_screen.dart';
import '../../find_doctor/care_discovery_screen.dart';
import '../../find_doctor/ui/doctor_detail_screen.dart';
import '../../find_doctor/ui/consultation_confirmed_screen.dart';
import '../../family_members/ui/family_members_screen.dart';

class AppRoutes {
  // Route names
  static const String landing = '/landing';
  static const String onboarding = '/onboarding';
  static const String doctors = '/doctors';
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointment_detail';
  static const String careDiscovery = '/care_discovery';
  static const String doctorDetail = '/doctor_detail';
  static const String consultationConfirmed = '/consultation_confirmed';
  static const String familyMembers = '/family_members';

  // Get pages
  static final List<GetPage> getPages = [
    GetPage(
      name: landing,
      page: () => const LandingPage(),
    ),
    GetPage(
      name: onboarding,
      page: () => const OnboardingScreen(),
    ),
    GetPage(
      name: doctors,
      page: () => const SearchDoctorsScreen(),
    ),
    GetPage(
      name: appointments,
      page: () => const AppointmentsScreen(),
    ),
    GetPage(
      name: appointmentDetail,
      page: () {
        final id = Get.arguments as String? ?? 'b1';
        return AppointmentDetailScreen(bookingId: id);
      },
    ),
    GetPage(
      name: careDiscovery,
      page: () {
        final args = Get.arguments as Map<String, dynamic>?;
        final entry = args?['entry'] as String? ?? 'Find Care';
        return CareDiscoveryScreen(entry: entry);
      },
    ),
    GetPage(
      name: doctorDetail,
      page: () {
        final id = (Get.arguments as Map<String, dynamic>?)?['id'] as String? ?? 'd1';
        return DoctorDetailScreen(doctorId: id);
      },
    ),
    GetPage(
      name: consultationConfirmed,
      page: () => const ConsultationConfirmedScreen(),
    ),
    GetPage(
      name: familyMembers,
      page: () => const FamilyMembersBottomSheet(),
    ),
  ];
}
