import 'package:get/get.dart';
import '../../family_member/ui/family_member_screen.dart';
import '../../health_records/ui/health_records_screen.dart';
import '../../landing/ui/landing_screen.dart';
import '../../onboarding/onboarding_screen.dart';
import '../../appointment/appointments_screen.dart';
import '../../appointment/appointment_detail_screen.dart';
import '../../care_discovery/ui/care_discovery_screen.dart';
import '../../care_discovery/ui/consultation_type_selection_screen.dart';
import '../../instant_consultation/ui/instant_consult_screen.dart';
import '../../booking/ui/doctor_booking_screen.dart';
import '../../consultation/ui/realtimekit_video_call_screen.dart';
import '../../consultation/entities/video_call_config.dart';

class AppRoutes {
  // Route names
  static const String landing = '/landing';
  static const String onboarding = '/onboarding';
  static const String doctors = '/doctors';
  static const String appointments = '/appointments';
  static const String appointmentDetail = '/appointment_detail';
  static const String careDiscovery = '/care_discovery';
  static const String consultationTypeSelection = '/consultation_type_selection';
  static const String doctorDetail = '/doctor_detail';
  static const String consultationConfirmed = '/consultation_confirmed';
  static const String familyMembers = '/family_members';
  static const String instantConsult = '/instant_consult';
  static const String healthRecords = '/health_records';
  static const String doctorBooking = '/doctor_booking';
  static const String videoCall = '/video_call';

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
    // GetPage(
    //   name: doctors,
    //   page: () => const SearchDoctorsScreen(),
    // ),
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
      name: consultationTypeSelection,
      page: () {
        final speciality = Get.arguments as String? ?? 'General';
        return ConsultationTypeSelectionScreen(speciality: speciality);
      },
    ),

    GetPage(
      name: familyMembers,
      page: () => const FamilyMembersBottomSheet(),
    ),
    GetPage(
      name: instantConsult,
      page: () => const InstantConsultScreen(),
    ),
    GetPage(
      name: healthRecords,
      page: () => const HealthRecordsScreen(),
    ),
    GetPage(
      name: doctorBooking,
      page: () {
        final id = (Get.arguments as Map<String, dynamic>?)?['id'] as String? ?? 'd1';
        return DoctorBookingScreen(doctorId: id);
      },
    ),
    GetPage(
      name: videoCall,
      page: () {
        final config = Get.arguments as VideoCallConfig;
        return RealtimeKitVideoCallScreen(config: config);
      },
    ),
  ];
}
