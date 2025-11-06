import 'package:get/get.dart';
import '../entities/pending_consultation.dart';
import '../service/consultation_service.dart';

class PendingConsultationController extends GetxController {
  final ConsultationService service;
  PendingConsultationController({ConsultationService? service}) : service = service ?? ConsultationService();

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final Rxn<PendingConsultation> consultation = Rxn<PendingConsultation>();

  Future<void> load(String appointmentId) async {
    isLoading.value = true;
    error.value = null;
    try {
      consultation.value = await service.getPendingConsultation(appointmentId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }
}

