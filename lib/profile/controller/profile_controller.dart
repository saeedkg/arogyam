import 'package:get/get.dart';
import '../service/profile_service.dart';
import '../../auth/entities/user_profile.dart';

class ProfileController extends GetxController {
  final ProfileService _service;

  ProfileController({ProfileService? service}) : _service = service ?? ProfileService();

  final isLoading = false.obs;
  final error = RxnString();
  final profile = Rxn<UserProfile>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    isLoading.value = true;
    error.value = null;
    try {
      final result = await _service.getProfile();
      profile.value = result;
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}


