import 'package:get/get.dart';
import 'current_patient.dart';
import 'current_patient_service.dart';

class CurrentPatientController extends GetxController {
  final CurrentPatientService service;
  CurrentPatientController({CurrentPatientService? service})
      : service = service ?? CurrentPatientService();

  final Rxn<CurrentPatient> current = Rxn<CurrentPatient>();
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    refreshFromPrefs();
  }

  Future<void> refreshFromPrefs() async {
    isLoading.value = true;
    try {
      current.value = await service.getOrInitCurrentPatient();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setCurrentPatient(CurrentPatient patient) async {
    await service.setCurrentPatient(patient);
    current.value = patient;
  }
}
