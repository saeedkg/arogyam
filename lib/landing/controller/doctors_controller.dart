import 'package:get/get.dart';
import '../entities/doctor_list_item.dart';
import '../service/doctors_api_service.dart';

class DoctorsController extends GetxController {
  final DoctorsApiService api;
  DoctorsController({DoctorsApiService? api}) : api = api ?? DoctorsApiService();

  final RxBool isLoading = false.obs;
  final RxList<DoctorListItem> allDoctors = <DoctorListItem>[].obs;
  final RxList<DoctorListItem> filtered = <DoctorListItem>[].obs;
  final RxString query = ''.obs;
  final RxString activeFilter = 'All'.obs;

  final List<String> filters = const ['All', 'General', 'Cardiologist', 'Dentist'];

  @override
  void onInit() {
    super.onInit();
    load();
    ever(query, (_) => _apply());
    ever(activeFilter, (_) => _apply());
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final items = await api.fetchDoctorsList();
      allDoctors.assignAll(items);
      _apply();
    } finally {
      isLoading.value = false;
    }
  }

  void _apply() {
    final q = query.value.toLowerCase();
    final f = activeFilter.value;
    filtered.assignAll(allDoctors.where((d) {
      final matchesQuery = q.isEmpty || d.name.toLowerCase().contains(q) || d.specialization.toLowerCase().contains(q);
      final matchesFilter = f == 'All' || d.specialization.toLowerCase().contains(f.toLowerCase());
      return matchesQuery && matchesFilter;
    }));
  }
}

