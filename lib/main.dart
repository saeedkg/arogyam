import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'auth/provider/auth_provider.dart';
import 'onboarding/onboarding_screen.dart';
import '_shared/routing/routing.dart';
import '_shared/ui/app_colors.dart';
import 'auth/request_otp_screen.dart';
import 'notification/service/fcm_service.dart';
import 'notification/service/notification_service.dart';
import 'notification/service/device_service.dart';
import 'notification/utils/notification_router.dart';
import 'notification/repository/notification_repository.dart';
import 'notification/controller/notification_controller.dart';
import 'notification/entities/requests/device_registration_request.dart';
import 'network/services/arogyam_api.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize FCM
  await FCMService.initialize();
  
  // Initialize local notifications
  await NotificationService.initialize();
  
  // Setup FCM listeners
  FCMService.setupForegroundMessageHandler((message) {
    // Show foreground notification
    NotificationService.showForegroundNotification(message);
  });
  
  FCMService.setupBackgroundMessageHandler();
  
  // Setup token refresh listener
  FCMService.setupTokenRefreshListener((newToken) async {
    print('🔄 Token refresh detected, updating backend...');
    
    // Get auth token from storage
    final prefs = await SharedPreferences.getInstance();
    final authToken = prefs.getString('auth_token');
    
    if (authToken != null) {
      // Token refresh will be handled by NotificationController
      // when it's initialized
    }
  });
  
  // Setup notification tap handler
  FCMService.setupNotificationTapHandler((message) {
    print('📱 Notification tapped: ${message.data}');
    // Navigate using NotificationRouter
    NotificationRouter.handleNotificationTap(message);
  });
  
  final prefs = await SharedPreferences.getInstance();
  final hasOnboarded = prefs.getBool('onboarding_complete') ?? false;
  
  // Initialize NotificationController if user is logged in
  _initializeNotificationController(prefs);
  
  // Re-register device if user is logged in
  _reRegisterDeviceIfLoggedIn(prefs);
  
  runApp(ArogyamApp(showOnboarding: !hasOnboarded));
}

/// Initialize NotificationController for logged-in users
void _initializeNotificationController(SharedPreferences prefs) {
  final authToken = prefs.getString('auth_token');
  
  if (authToken != null) {
    // User is logged in, initialize NotificationController
    final userRole = prefs.getString('user_role') ?? 'patient';
    final api = AROGYAMAPI();
    final repository = NotificationRepository(api, userRole);
    
    // Use Get.put to initialize the controller
    Get.put(NotificationController(repository), permanent: true);
    
    print('✅ NotificationController initialized');
  }
}

/// Re-register device on app launch to update last_used_at
void _reRegisterDeviceIfLoggedIn(SharedPreferences prefs) {
  Future.microtask(() async {
    try {
      final authToken = prefs.getString('auth_token');
      
      if (authToken != null) {
        print('🔄 Re-registering device on app launch...');
        
        // Get device ID
        final deviceId = await DeviceService.getOrCreateDeviceId();
        
        // Get device info
        final deviceInfo = await DeviceService.getDeviceInfo();
        
        // Get FCM token
        final fcmToken = await FCMService.getToken();
        
        if (fcmToken == null) {
          print('⚠️ No FCM token available');
          return;
        }
        
        // Get user role
        final userRole = prefs.getString('user_role') ?? 'patient';
        
        // Create registration request
        final request = DeviceRegistrationRequest(
          deviceId: deviceId,
          deviceName: deviceInfo['device_name'],
          deviceType: deviceInfo['device_type']!,
          deviceModel: deviceInfo['device_model'],
          deviceOsVersion: deviceInfo['device_os_version'],
          appVersion: deviceInfo['app_version'],
          fcmToken: fcmToken,
        );
        
        // Register with backend
        final api = AROGYAMAPI();
        final repository = NotificationRepository(api, userRole);
        final response = await repository.registerDevice(request);
        
        if (response.statusCode == 200) {
          print('✅ Device re-registered successfully');
          await DeviceService.markDeviceRegistered();
        } else {
          print('❌ Device re-registration failed: ${response.statusCode}');
        }
      }
    } catch (e) {
      print('❌ Error re-registering device: $e');
    }
  });
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
