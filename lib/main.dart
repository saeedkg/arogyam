import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth/provider/auth_provider.dart';
import 'onboarding/onboarding_screen.dart';
import '_shared/routing/routing.dart';
import '_shared/ui/app_colors.dart';
import 'auth/request_otp_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool('onboarding_complete') ?? false;
  runApp(ArogyamApp(showOnboarding: !hasOnboarded));
}

class ArogyamApp extends StatelessWidget {
  final bool showOnboarding;
  const ArogyamApp({super.key, required this.showOnboarding});

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
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.infoBlue),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: showOnboarding ? const OnboardingScreen() : const RequestOtpScreen(),
        getPages: AppRoutes.getPages,
      ),
    );
  }
}

Future<void> setOnboardingCompleted() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('onboarding_complete', true);
}
