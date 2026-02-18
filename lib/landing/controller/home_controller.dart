import 'package:get/get.dart';
import '../../appointment/entities/appointment.dart';
import '../../auth/user_management/service/auth_token_provider.dart';
import '../../common_services/entities/doctor.dart' as common_doctor;
import '../../common_services/entities/specialization.dart';
import '../../common_services/services/doctor_service.dart';
import '../../common_services/services/specialization_service.dart';
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

  HomeController({
    MockApiService? api,
    DoctorService? doctorService,
    SpecializationService? specializationService,
    DashboardService? dashboardService,
  })  : api = api ?? MockApiService(),
        doctorService = doctorService ?? DoctorService(),
        specializationService = specializationService ?? SpecializationService(),
        dashboardService = dashboardService ?? DashboardService();

  final Rxn<Appointment> nextAppointment = Rxn<Appointment>();
  final RxList<CategoryItem> categories = <CategoryItem>[].obs;
  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxList<Doctor> topDoctors = <Doctor>[].obs;
  final RxList<UpcomingAppointment> upcomingAppointments = <UpcomingAppointment>[].obs;
  final RxList<ConsultationToJoin> consultationsToJoin = <ConsultationToJoin>[].obs;
  final Rxn<DashboardData> dashboardData = Rxn<DashboardData>();
  final RxBool isLoading = false.obs;
  final RxInt bannerIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadAll();
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
        resultIndex++;
      } else {
        // Clear appointments for guest users
        upcomingAppointments.clear();
        consultationsToJoin.clear();
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
      } else {
        // Clear appointments for guest users
        upcomingAppointments.clear();
        consultationsToJoin.clear();
      }
    } catch (e) {
      print('Error refreshing dashboard data: $e');
    }
  }
}
