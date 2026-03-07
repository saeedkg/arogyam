import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../../appointment/entities/appointment.dart';
import '../../auth/user_management/service/auth_token_provider.dart';
import '../../auth/service/logout_service.dart';
import '../../_shared/routing/app_navigation.dart';
import '../../common_services/entities/doctor.dart' as common_doctor;
import '../../common_services/entities/specialization.dart';
import '../../common_services/services/doctor_service.dart';
import '../../common_services/services/specialization_service.dart';
import '../../network/exceptions/token_invalid_exception.dart';
import '../../notification/service/fcm_service.dart';
import '../../notification/service/device_service.dart';
import '../../notification/service/notification_service.dart';
import '../../notification/controller/notification_controller.dart';
import '../../location/controller/location_controller.dart';
import '../entities/banner_item.dart';
import '../entities/category_item.dart';
import '../entities/doctor.dart';
import '../entities/dashboard_data.dart';
import '../service/mock_api_service.dart';
import '../service/dashboard_service.dart';

class HomeController extends GetxController {
  final MockApiService api;
  final DoctorService doctorService;
  final SpecializationService specializationService;
  final DashboardService dashboardService;
  final LocationController locationController;

  HomeController({
    MockApiService? api,
    DoctorService? doctorService,
    SpecializationService? specializationService,
    DashboardService? dashboardService,
    LocationController? locationController,
  })  : api = api ?? MockApiService(),
        doctorService = doctorService ?? DoctorService(),
        specializationService = specializationService ?? SpecializationService(),
        dashboardService = dashboardService ?? DashboardService(),
        locationController = locationController ?? Get.put(LocationController());

  final Rxn<Appointment> nextAppointment = Rxn<Appointment>();
  final RxList<CategoryItem> categories = <CategoryItem>[].obs;
  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxList<Doctor> topDoctors = <Doctor>[].obs;
  final RxList<UpcomingAppointment> upcomingAppointments = <UpcomingAppointment>[].obs;
  final RxList<ConsultationToJoin> consultationsToJoin = <ConsultationToJoin>[].obs;
  final RxList<FollowUpChatSummary> followUpChats = <FollowUpChatSummary>[].obs;
  final Rxn<DashboardData> dashboardData = Rxn<DashboardData>();
  final RxBool isLoading = false.obs;
  final RxInt bannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
    _loadUserLocation();
  }
  
  /// Load user location in background
  Future<void> _loadUserLocation() async {
    await locationController.getCurrentLocation();
  }

  Future<void> loadAll() async {
    isLoading.value = true;
    try {
      // Check if user is in guest mode
      final authTokenProvider = AuthTokenProvider();
      final token = await authTokenProvider.getToken();
      final isGuestMode = token == null;
      
      List<Future> futures = [];
      
      // Only call dashboard API if user is authenticated
      if (!isGuestMode) {
        futures.add(dashboardService.fetchDashboardData());
      }
      
      // Always load public data (specializations, banners, doctors)
      futures.addAll([
        specializationService.fetchSpecializations(),
        api.fetchBanners(),
        doctorService.fetchDoctors(),
      ]);
      
      final results = await Future.wait(futures);
      
      int resultIndex = 0;
      
      // Process dashboard data only if user is authenticated
      if (!isGuestMode) {
        dashboardData.value = results[resultIndex] as DashboardData;
        upcomingAppointments.assignAll(dashboardData.value!.upcomingAppointments);
        consultationsToJoin.assignAll(dashboardData.value!.consultationsToJoin);
        followUpChats.assignAll(dashboardData.value!.followUpChats);
        resultIndex++;
      } else {
        // Clear appointments for guest users
        upcomingAppointments.clear();
        consultationsToJoin.clear();
        followUpChats.clear();
      }
      
      // Map specializations to categories
      final specializations = results[resultIndex] as List<Specialization>;
      categories.assignAll(
        specializations.take(8).map((s) => CategoryItem(
          id: s.id.toString(),
          name: s.name,
          svgIcon: s.svgIcon,
        )).toList(),
      );
      resultIndex++;
      
      banners.assignAll(results[resultIndex] as List<BannerItem>);
      resultIndex++;
      
      // Map doctors from common service to landing entity
      final doctors = results[resultIndex] as List<common_doctor.Doctor>;
      topDoctors.assignAll(
        doctors.take(10).map((d) => Doctor(
          id: d.id.toString(),
          name: d.name,
          specialization: d.qualifications.isNotEmpty 
              ? d.qualifications.first 
              : 'General Physician',
          imageUrl: d.imageUrl.isNotEmpty 
              ? d.imageUrl 
              : "",
          rating: d.averageRating > 0 ? d.averageRating : 4.8,
        )).toList(),
      );
    } catch (e) {
      // Handle TOKEN_INVALID exception
      if (e is TokenInvalidException) {
        isLoading.value = false; // Stop loading before showing dialog
        await _handleTokenInvalid(e.userReadableMessage);
        return; // Exit after handling token invalid
      }
      
      print('Error loading dashboard data: $e');
      // Continue loading other data even if dashboard fails
      try {
        final results = await Future.wait([
          specializationService.fetchSpecializations(),
          api.fetchBanners(),
          doctorService.fetchDoctors(),
        ]);
        
        final specializations = results[0] as List<Specialization>;
        categories.assignAll(
          specializations.take(8).map((s) => CategoryItem(
            id: s.id.toString(),
            name: s.name,
            svgIcon: s.svgIcon,
          )).toList(),
        );
        
        banners.assignAll(results[1] as List<BannerItem>);
        
        final doctors = results[2] as List<common_doctor.Doctor>;
        topDoctors.assignAll(
          doctors.take(10).map((d) => Doctor(
            id: d.id.toString(),
            name: d.name,
            specialization: d.qualifications.isNotEmpty 
                ? d.qualifications.first 
                : 'General Physician',
            imageUrl: d.imageUrl.isNotEmpty 
                ? d.imageUrl 
                : "",
            rating: d.averageRating > 0 ? d.averageRating : 4.8,
          )).toList(),
        );
      } catch (e) {
        print('Error loading fallback data: $e');
      }
    } finally {
      isLoading.value = false;
    }
  }

  /// Refresh only dashboard data (appointments, consultations to join, unread counts)
  Future<void> refreshDashboardData() async {
    try {
      // Check if user is in guest mode
      final authTokenProvider = AuthTokenProvider();
      final token = await authTokenProvider.getToken();
      final isGuestMode = token == null;
      
      // Only call dashboard API if user is authenticated
      if (!isGuestMode) {
        final data = await dashboardService.fetchDashboardData();
        dashboardData.value = data;
        upcomingAppointments.assignAll(data.upcomingAppointments);
        consultationsToJoin.assignAll(data.consultationsToJoin);
        followUpChats.assignAll(data.followUpChats);
      } else {
        // Clear appointments for guest users
        upcomingAppointments.clear();
        consultationsToJoin.clear();
        followUpChats.clear();
      }
    } catch (e) {
      // Handle TOKEN_INVALID exception
      if (e is TokenInvalidException) {
        await _handleTokenInvalid(e.userReadableMessage);
        return;
      }
      
      print('Error refreshing dashboard data: $e');
    }
  }

  /// Handle TOKEN_INVALID exception - show alert and force logout
  Future<void> _handleTokenInvalid(String message) async {
    // Show alert dialog
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Session Expired',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        content: Text(message),
        actions: [
          ElevatedButton(
            onPressed: () {
              // Return true to indicate user wants to logout
              Get.back(result: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Login Again'),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    
    // If user clicked the button, show loading and perform logout
    if (result == true) {
      // Show loading dialog
      Get.dialog(
        PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Logging out...',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
        barrierDismissible: false,
      );
      
      // Perform logout cleanup
      try {
        print('🔄 Starting forced logout cleanup...');
        
        // Clear FCM token
        await FCMService.deleteToken();
        
        // Clear notification data
        await DeviceService.clearRegistrationStatus();
        await NotificationService.clearHistory();
        
        // Delete NotificationController
        if (Get.isRegistered<NotificationController>()) {
          Get.delete<NotificationController>();
          print('✅ NotificationController deleted on forced logout');
        }
        
        // Clear all local user data
        await LogoutService().clearAllUserData();
        
        print('✅ Forced logout completed successfully');
      } catch (e) {
        print('⚠️ Error during forced logout cleanup: $e');
        // Continue to navigation even if cleanup fails
      }
      
      // Close loading dialog
      Get.back();
      
      // Navigate to login screen
      print('🚀 Navigating to login screen...');
      AppNavigation.offAllToRequestOtpScreen();
    }
  }
}
