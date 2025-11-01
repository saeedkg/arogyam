import 'package:get/get.dart';
import '../../appointment/entities/appointment.dart';
import '../../common_services/entities/doctor.dart' as CommonDoctor;
import '../../common_services/services/doctor_service.dart';
import '../entities/banner_item.dart';
import '../entities/category_item.dart';
import '../entities/doctor.dart';
import '../service/mock_api_service.dart';

class HomeController extends GetxController {
  final MockApiService api;
  final DoctorService doctorService;

  HomeController({
    MockApiService? api,
    DoctorService? doctorService,
  })  : api = api ?? MockApiService(),
        doctorService = doctorService ?? DoctorService();

  final Rxn<Appointment> nextAppointment = Rxn<Appointment>();
  final RxList<CategoryItem> categories = <CategoryItem>[].obs;
  final RxList<BannerItem> banners = <BannerItem>[].obs;
  final RxList<Doctor> topDoctors = <Doctor>[].obs;
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
      final results = await Future.wait([
        api.fetchNextAppointment(),
        api.fetchCategories(),
        api.fetchBanners(),
        doctorService.fetchDoctors(),
      ]);
      nextAppointment.value = results[0] as Appointment?;
      categories.assignAll(results[1] as List<CategoryItem>);
      banners.assignAll(results[2] as List<BannerItem>);
      
      // Map doctors from common service to landing entity
      final doctors = results[3] as List<CommonDoctor.Doctor>;
      topDoctors.assignAll(
        doctors.take(10).map((d) => Doctor(
          id: d.id.toString(),
          name: d.name,
          specialization: d.qualifications.isNotEmpty 
              ? d.qualifications.first 
              : 'General Physician',
         // imageUrl: d.imageUrl,
          imageUrl: "https://i.pravatar.cc/150?img=47",
          rating: d.averageRating > 0 ? d.averageRating : 4.8,
        )).toList(),
      );
    } finally {
      isLoading.value = false;
    }
  }
}

