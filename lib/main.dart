import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'auth/provider/auth_provider.dart';
import 'auth/request_otp_screen.dart';
import 'landing/ui/landing_page.dart';

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
        ),
        home: const RequestOtpScreen(),
        getPages: [
          GetPage(name: '/landing', page: () => const LandingPage()),
        ],
      ),
    );
  }
}
