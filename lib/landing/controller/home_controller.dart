import 'package:get/get.dart';
import '../entities/appointment.dart';
import '../entities/banner_item.dart';
import '../entities/category_item.dart';
import '../entities/doctor.dart';
import '../service/mock_api_service.dart';

class HomeController extends GetxController {
  final MockApiService api;

  HomeController({MockApiService? api}) : api = api ?? MockApiService();

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
        api.fetchTopDoctors(),
      ]);
      nextAppointment.value = results[0] as Appointment?;
      categories.assignAll(results[1] as List<CategoryItem>);
      banners.assignAll(results[2] as List<BannerItem>);
      topDoctors.assignAll(results[3] as List<Doctor>);
    } finally {
      isLoading.value = false;
    }
  }
}

