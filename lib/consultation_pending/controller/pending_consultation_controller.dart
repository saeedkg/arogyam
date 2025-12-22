import 'package:get/get.dart';
import '../entities/appointment_detail.dart';
import '../service/consultation_service.dart';
import '../../health_records/entities/health_record.dart';
import '../../health_records/service/health_records_service.dart';

class PendingConsultationController extends GetxController {
  final ConsultationService service;
  final HealthRecordsService healthRecordsService;
  
  PendingConsultationController({
    ConsultationService? service,
    HealthRecordsService? healthRecordsService,
  }) : service = service ?? ConsultationService(),
       healthRecordsService = healthRecordsService ?? HealthRecordsService();

  final RxBool isLoading = false.obs;
  final RxnString error = RxnString();
  final Rxn<AppointmentDetails> consultation = Rxn<AppointmentDetails>();
  
  final RxBool isLoadingHealthRecords = false.obs;
  final RxList<HealthRecord> healthRecords = <HealthRecord>[].obs;
  final RxnString healthRecordsError = RxnString();

  Future<void> load(String appointmentId) async {
    isLoading.value = true;
    error.value = null;
    try {
      consultation.value = await service.getPendingConsultation(appointmentId);
      // Load health records for this appointment
      await loadHealthRecords(appointmentId);
    } catch (e) {
      error.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadHealthRecords(String appointmentId) async {
    isLoadingHealthRecords.value = true;
    healthRecordsError.value = null;
    try {
      final records = await healthRecordsService.fetchHealthRecordsForAppointment(appointmentId);
      healthRecords.assignAll(records);
    } catch (e) {
      healthRecordsError.value = e.toString();
      print('Error loading health records: $e');
    } finally {
      isLoadingHealthRecords.value = false;
    }
  }

  Future<void> refreshHealthRecords(String appointmentId) async {
    await loadHealthRecords(appointmentId);
  }
}

