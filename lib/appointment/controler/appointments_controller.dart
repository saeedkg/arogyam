import 'package:get/get.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../entities/appointemet_detail.dart';
import '../entities/appointment.dart';
import '../service/appointments_service.dart';


class AppointmentsController extends GetxController {
  final AppointmentsService api;
  
  AppointmentsController({AppointmentsService? api})
      : api = api ?? AppointmentsService();

  final RxBool isLoading = false.obs;
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxString errorMessage = ''.obs;

  final RxBool isDetailLoading = false.obs;
  final Rxn<AppointmentDetail> appointmentDetail = Rxn<AppointmentDetail>();

  String? _currentPatientId;

  @override
  void onInit() {
    super.onInit();
    fetchInitialAppointments();
  }

  /// Set patient ID and reload appointments
  void setPatientId(String? patientId) {
    if (_currentPatientId != patientId) {
      _currentPatientId = patientId;
      fetchInitialAppointments();
    }
  }

  /// Fetch initial appointments (first page)
  Future<void> fetchInitialAppointments() async {
    _setLoading(true);
    _clearError();
    appointments.clear();
    
    try {
      final result = await api.fetchAppointments(
        reset: true,
        patientId: _currentPatientId,
      );
      
      appointments.assignAll(result);
    } on NetworkFailureException {
      _setError('No internet connection. Please check your network and try again.');
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Fetch more appointments (next page) for pagination
  Future<void> fetchMoreAppointments() async {
    if (isLoading.value || api.didReachListEnd) return;
    
    _setLoading(true);
    _clearError();
    
    try {
      final result = await api.fetchAppointments(
        patientId: _currentPatientId,
      );
      
      appointments.addAll(result);
    } on NetworkFailureException {
      _setError('No internet connection. Please check your network and try again.');
    } catch (e) {
      _setError(_getErrorMessage(e));
    } finally {
      _setLoading(false);
    }
  }

  /// Pull to refresh
  Future<void> refreshAppointments() async {
    await fetchInitialAppointments();
  }

  void _setLoading(bool value) {
    isLoading.value = value;
  }

  void _clearError() {
    errorMessage.value = '';
  }

  void _setError(String message) {
    errorMessage.value = message;
  }

  String _getErrorMessage(dynamic error) {
    if (error is ServerSentException) {
      return error.userReadableMessage;
    }
    return error.toString().replaceAll('Exception: ', '');
  }

  Future<void> fetchAppointmentDetail(int id) async {
    isDetailLoading.value = true;
    appointmentDetail.value = null;
    try {
      final result = await api.fetchAppointmentDetail(id);
      appointmentDetail.value = result;
    } catch (e) {
      errorMessage.value = _getErrorMessage(e);
    } finally {
      isDetailLoading.value = false;
    }
  }
}
