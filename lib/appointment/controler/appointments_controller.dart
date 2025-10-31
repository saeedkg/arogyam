import 'package:get/get.dart';
import '../entities/appointemet_detail.dart';
import '../entities/appointment.dart';
import '../service/appointments_service.dart';


class AppointmentsController extends GetxController {
  final AppointmentsService service;
  AppointmentsController({AppointmentsService? service})
      : service = service ?? AppointmentsService();

  final RxBool isLoading = false.obs;
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxnString errorMessage = RxnString();

  final RxBool isDetailLoading = false.obs;
  final Rxn<AppointmentDetail> appointmentDetail = Rxn<AppointmentDetail>();

  @override
  void onInit() {
    super.onInit();
    fetchAppointments();
  }

  Future<void> fetchAppointments() async {
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final result = await service.fetchAppointments();
      appointments.assignAll(result);
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchAppointmentDetail(int id) async {
    isDetailLoading.value = true;
    appointmentDetail.value = null;
    try {
      final result = await service.fetchAppointmentDetail(id);
      appointmentDetail.value = result;
    } catch (e) {
      errorMessage.value = e.toString();
    } finally {
      isDetailLoading.value = false;
    }
  }
}
