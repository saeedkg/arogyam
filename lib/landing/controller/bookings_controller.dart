import 'package:get/get.dart';
import '../entities/booking.dart';
import '../service/mock_api_service.dart';

class BookingsController extends GetxController {
  final MockApiService api;
  BookingsController({MockApiService? api}) : api = api ?? MockApiService();

  final RxBool isLoading = false.obs;
  final RxInt tabIndex = 0.obs; // 0 upcoming, 1 completed, 2 canceled
  final RxList<BookingItem> items = <BookingItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
    ever(tabIndex, (_) => load());
  }

  Future<void> load() async {
    isLoading.value = true;
    try {
      final status = tabIndex.value == 0 ? 'upcoming' : tabIndex.value == 1 ? 'completed' : 'canceled';
      final result = await api.fetchBookings(status);
      items.assignAll(result);
    } finally {
      isLoading.value = false;
    }
  }
}

