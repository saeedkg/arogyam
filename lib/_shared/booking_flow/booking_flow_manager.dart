import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../consultation/consultation_type.dart';
import '../../care_discovery/ui/care_discovery_screen.dart';
import '../../care_discovery/ui/consultation_type_selection_screen.dart';
import '../../find_doctor/ui/speciality_doctors_screen.dart';
import '../../booking/ui/doctor_booking_screen.dart';
import '../../consultation_pending/ui/pending_consultation_screen.dart';
import 'entities/flow_result.dart';

enum BookingFlowEntry {
  dashboard,           // Start from care discovery
  quickAction,         // Start with pre-selected consultation type
  doctorProfile,       // Start from specific doctor
  specializationFilter // Start from specialization listing
}

class BookingFlowManager {
  static BookingFlowManager? _instance;
  static BookingFlowManager get instance {
    _instance ??= BookingFlowManager._();
    return _instance!;
  }

  BookingFlowManager._();

  /// Start the complete booking flow from dashboard
  Future<void> startBookingFlow({
    BookingFlowEntry entry = BookingFlowEntry.dashboard,
    String? selectedSpecialization,
    AppointmentType? appointmentType,
    String? selectedDoctorId,
  }) async {
    try {
      switch (entry) {
        case BookingFlowEntry.dashboard:
          await _startFromDashboard(appointmentType);
          break;
        case BookingFlowEntry.quickAction:
          await _startFromQuickAction(selectedSpecialization, appointmentType);
          break;
        case BookingFlowEntry.doctorProfile:
          await _startFromDoctorProfile(selectedDoctorId, appointmentType);
          break;
        case BookingFlowEntry.specializationFilter:
          await _startFromSpecializationFilter(selectedSpecialization, appointmentType);
          break;
      }
    } catch (e) {
      print('BookingFlowManager Error: $e');
      // Show error to user
      Get.snackbar(
        'Booking Error',
        'Something went wrong. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade800,
      );
    }
  }

  /// Start flow from dashboard - goes to care discovery first
  Future<void> _startFromDashboard(AppointmentType? preSelectedAppointmentType) async {
    Navigator.push<FlowResult<Map<String, dynamic>>>(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => CareDiscoveryScreen(
          entry: 'Find Care',
          preSelectedAppointmentType: preSelectedAppointmentType,
        ),
      ),
    ).then((result) {
      if (result != null) {
        if (result.isSuccess && result.data != null) {
          final selectedSpecialization = result.data!['selectedSpecialization'] as String?;
          final appointmentType = result.data!['appointmentType'] as AppointmentType?;
          
          if (selectedSpecialization != null) {
            if (appointmentType != null) {
              // Appointment type already selected, go to doctors
              _navigateToSpecialityDoctors(selectedSpecialization, appointmentType);
            } else {
              // Need to select consultation type
              _navigateToConsultationTypeSelection(selectedSpecialization);
            }
          }
        } else if (result.isError) {
          _handleFlowError(result.errorMessage ?? 'Unknown error occurred');
        }
        // If cancelled, do nothing (user backed out)
      }
    });
  }

  /// Start flow with pre-selected appointment type
  Future<void> _startFromQuickAction(String? selectedSpecialization, AppointmentType? appointmentType) async {
    if (appointmentType != null && selectedSpecialization != null) {
      // Skip to doctor listing directly
      _navigateToSpecialityDoctors(selectedSpecialization, appointmentType);
    } else {
      // Still need to select specialization
      _startFromDashboard(appointmentType);
    }
  }

  /// Start flow from doctor profile - skip to booking
  Future<void> _startFromDoctorProfile(String? selectedDoctorId, AppointmentType? appointmentType) async {
    if (selectedDoctorId != null) {
      _navigateToDoctorBooking(selectedDoctorId);
    } else {
      // Fallback to normal flow
      _startFromDashboard(appointmentType);
    }
  }

  /// Start flow from specialization filter
  Future<void> _startFromSpecializationFilter(String? selectedSpecialization, AppointmentType? appointmentType) async {
    if (selectedSpecialization != null) {
      if (appointmentType != null) {
        // Appointment type already selected, go directly to doctors
        _navigateToSpecialityDoctors(selectedSpecialization, appointmentType);
      } else {
        // Need to select consultation type first
        _navigateToConsultationTypeSelection(selectedSpecialization);
      }
    } else {
      _startFromDashboard(appointmentType);
    }
  }

  /// Navigate to consultation type selection
  void _navigateToConsultationTypeSelection(String selectedSpecialization) {
    Navigator.push<FlowResult<AppointmentType>>(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => ConsultationTypeSelectionScreen(
          speciality: selectedSpecialization,
        ),
      ),
    ).then((result) {
      if (result != null) {
        if (result.isSuccess && result.data != null) {
          _navigateToSpecialityDoctors(selectedSpecialization, result.data!);
        } else if (result.isError) {
          _handleFlowError(result.errorMessage ?? 'Unknown error occurred');
        }
        // If cancelled, do nothing (user backed out)
      }
    });
  }

  /// Navigate to speciality doctors screen
  void _navigateToSpecialityDoctors(String selectedSpecialization, AppointmentType? appointmentType) {
    Navigator.push<FlowResult<String>>(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => SpecialityDoctorsScreen(
          category: selectedSpecialization,
          appointmentType: appointmentType,
        ),
      ),
    ).then((result) {
      if (result != null) {
        if (result.isSuccess && result.data != null) {
          _navigateToDoctorBooking(result.data!);
        } else if (result.isError) {
          _handleFlowError(result.errorMessage ?? 'Unknown error occurred');
        }
        // If cancelled, do nothing (user backed out)
      }
    });
  }

  /// Navigate to doctor booking screen
  void _navigateToDoctorBooking(String selectedDoctorId) {
    Navigator.push<FlowResult<Map<String, dynamic>>>(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => DoctorBookingScreen(
          doctorId: selectedDoctorId,
        ),
      ),
    ).then((result) {
      if (result != null) {
        if (result.isSuccess && result.data != null) {
          final appointmentId = result.data!['appointmentId'] as String?;
          
          if (appointmentId != null) {
            // Payment is handled inside DoctorBookingScreen, go directly to PendingConsultation
            _navigateToPendingConsultation(appointmentId);
          }
        } else if (result.isError) {
          _handleFlowError(result.errorMessage ?? 'Booking failed');
        }
        // If cancelled, do nothing (user backed out)
      }
    });
  }

  /// Navigate to pending consultation (normal navigation, don't clear stack yet)
  void _navigateToPendingConsultation(String appointmentId) {
    // Use normal navigation - let PendingConsultationScreen handle back navigation
    Navigator.push(
      Get.context!,
      MaterialPageRoute(
        builder: (context) => PendingConsultationScreen(appointmentId: appointmentId),
      ),
    );
  }

  /// Handle flow errors
  void _handleFlowError(String errorMessage) {
    print('BookingFlow Error: $errorMessage');
    Get.snackbar(
      'Booking Error',
      errorMessage,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red.shade100,
      colorText: Colors.red.shade800,
      duration: const Duration(seconds: 3),
    );
  }

  /// Utility method for direct navigation (backward compatibility)
  void navigateToSpecialityDoctors({
    required String category,
    AppointmentType? appointmentType,
  }) {
    _navigateToSpecialityDoctors(category, appointmentType);
  }

  /// Utility method for direct doctor booking navigation
  void navigateToDoctorBooking(String doctorId) {
    _navigateToDoctorBooking(doctorId);
  }

  /// Utility method for pending consultation navigation
  void navigateToPendingConsultation(String appointmentId) {
    _navigateToPendingConsultation(appointmentId);
  }
}