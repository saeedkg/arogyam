import 'package:get/get.dart';
import '../entities/Patient.dart';
import '../service/patient_service.dart';

class ChosePatientController extends GetxController {
  final PatientService _service;
  ChosePatientController({PatientService? service}) : _service = service ?? PatientService();

  final isLoading = false.obs;
  final error = RxnString();
  final members = <Patient>[].obs;

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
      final created = await _service.addFamilyMember(Patient(
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


