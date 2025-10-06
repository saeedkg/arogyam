import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth/provider/auth_provider.dart';
import 'auth/request_otp_screen.dart';
import 'landing/ui/landing_page.dart';
import 'onboarding/onboarding_screen.dart';
import 'landing/ui/pages/search_doctors_screen.dart';
import 'appointment/appointments_screen.dart';
import 'appointment/appointment_detail_screen.dart';
import 'landing/ui/pages/care_discovery_screen.dart';

void main() {
  runApp(const ArogyamApp());
}

class ArogyamApp extends StatelessWidget {
  const ArogyamApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: GetMaterialApp(
        title: 'Arogyam',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const OnboardingScreen(),
        getPages: [
          GetPage(name: '/landing', page: () => const LandingPage()),
          GetPage(name: '/onboarding', page: () => const OnboardingScreen()),
          GetPage(name: '/doctors', page: () => const SearchDoctorsScreen()),
          GetPage(name: '/appointments', page: () => const AppointmentsScreen()),
          GetPage(name: '/appointment_detail', page: () {
            final id = Get.arguments as String? ?? 'b1';
            return AppointmentDetailScreen(bookingId: id);
          }),
          GetPage(name: '/care_discovery', page: () {
            final args = Get.arguments as Map<String, dynamic>?;
            final entry = args?['entry'] as String? ?? 'Find Care';
            return CareDiscoveryScreen(entry: entry);
          }),
        ],
      ),
    );
  }
}
