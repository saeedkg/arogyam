import 'package:get/get.dart';
import '../entities/family_member.dart';
import '../service/family_service.dart';

class FamilyMembersController extends GetxController {
  final FamilyService _service;
  FamilyMembersController({FamilyService? service}) : _service = service ?? FamilyService();

  final isLoading = false.obs;
  final error = RxnString();
  final members = <FamilyMember>[].obs;

  @override
  void onInit() {
    super.onInit();
    load();
  }

  Future<void> load() async {
    isLoading.value = true;
    error.value = null;
    try {
      final list = await _service.getFamilyMembers();
      members.assignAll(list);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> addMember({
    required String name,
    required String relation,
    required String dateOfBirth, // yyyy-MM-dd
    required String gender,
    required String bloodGroup,
  }) async {
    try {
      final created = await _service.addFamilyMember(FamilyMember(
        id: '0',
        name: name,
        relation: relation,
        dateOfBirth: dateOfBirth,
        gender: gender,
        bloodGroup: bloodGroup,
      ));
      members.insert(0, created);
      return true;
    } catch (_) {
      return false;
    }
  }
}


