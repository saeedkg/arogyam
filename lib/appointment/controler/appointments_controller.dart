import 'package:get/get.dart';
import '../../network/exceptions/network_failure_exception.dart';
import '../../network/exceptions/server_sent_exception.dart';
import '../entities/appointment.dart';
import '../entities/appointment_status.dart';
import '../service/appointments_service.dart';

enum AppointmentFilter { all, upcoming, past }

class AppointmentsController extends GetxController {
  final AppointmentsService api;
  
  AppointmentsController({AppointmentsService? api})
      : api = api ?? AppointmentsService();

  final RxBool isLoading = false.obs;
  final RxList<Appointment> appointments = <Appointment>[].obs;
  final RxString errorMessage = ''.obs;
  final Rx<AppointmentFilter> selectedFilter = AppointmentFilter.all.obs;

  final RxBool isDetailLoading = false.obs;

  String? _currentPatientId;

  @override
  void onInit() {
    super.onInit();
    // Don't fetch appointments automatically - let the screen control this
    // fetchInitialAppointments();
  }

  /// Set patient ID and reload appointments
  void setPatientId(String? patientId) {
    _currentPatientId = patientId;
    fetchInitialAppointments();
  }

  /// Get current patient ID
  String? get currentPatientId => _currentPatientId;

  /// Set filter and reload appointments from API
  void setFilter(AppointmentFilter filter) {
    selectedFilter.value = filter;
    fetchInitialAppointments();
  }

  /// Get API status parameter based on filter
  String? _getStatusParameter() {
    switch (selectedFilter.value) {
      case AppointmentFilter.all:
        return null; // No status filter for "all"
      case AppointmentFilter.upcoming:
        return 'upcoming'; // API should return upcoming appointments
      case AppointmentFilter.past:
        return 'completed'; // API should return completed appointments
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
        status: _getStatusParameter(),
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
        status: _getStatusParameter(),
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


}
