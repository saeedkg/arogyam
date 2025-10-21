import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'auth/provider/auth_provider.dart';
import 'onboarding/onboarding_screen.dart';
import '_shared/routing/routing.dart';
import '_shared/ui/app_colors.dart';

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
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.infoBlue),
          useMaterial3: true,
          textTheme: GoogleFonts.poppinsTextTheme(),
        ),
        home: const OnboardingScreen(),
        getPages: AppRoutes.getPages,
      ),
    );
  }
}
