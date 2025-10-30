import 'package:get/get.dart';
import '../entities/health_record.dart';
import '../service/health_records_service.dart';

class HealthRecordsController extends GetxController {
  final HealthRecordsService api;

  HealthRecordsController({HealthRecordsService? api}) : api = api ?? HealthRecordsService();

  final RxBool isLoading = false.obs;
  final RxList<HealthRecord> healthRecords = <HealthRecord>[].obs;

  @override
  void onInit() {
    super.onInit();
    loadHealthRecords();
  }

  Future<void> loadHealthRecords() async {
    isLoading.value = true;
    try {
      final records = await api.fetchHealthRecords();
      healthRecords.assignAll(records);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshRecords() async {
    await loadHealthRecords();
  }
}
