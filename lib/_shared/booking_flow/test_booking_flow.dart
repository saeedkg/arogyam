import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'booking_flow_manager.dart';
import '../consultation/consultation_type.dart';

/// Test class for booking flow scenarios
/// This is for development testing only
class BookingFlowTester {
  static void testDashboardFlow() {
    print('🧪 Testing Dashboard Flow...');
    BookingFlowManager.instance.startBookingFlow(
      entry: BookingFlowEntry.dashboard,
    );
  }

  static void testQuickActionVideoFlow() {
    print('🧪 Testing Quick Action Video Flow...');
    BookingFlowManager.instance.startBookingFlow(
      entry: BookingFlowEntry.quickAction,
      appointmentType: AppointmentType.video,
    );
  }

  static void testQuickActionClinicFlow() {
    print('🧪 Testing Quick Action Clinic Flow...');
    BookingFlowManager.instance.startBookingFlow(
      entry: BookingFlowEntry.quickAction,
      appointmentType: AppointmentType.clinic,
    );
  }

  static void testSpecializationFlow() {
    print('🧪 Testing Specialization Flow...');
    BookingFlowManager.instance.startBookingFlow(
      entry: BookingFlowEntry.specializationFilter,
      selectedSpecialization: 'Cardiology',
    );
  }

  static void testDoctorProfileFlow() {
    print('🧪 Testing Doctor Profile Flow...');
    BookingFlowManager.instance.startBookingFlow(
      entry: BookingFlowEntry.doctorProfile,
      selectedDoctorId: 'doctor123',
      selectedSpecialization: 'General Medicine',
      appointmentType: AppointmentType.video,
    );
  }

  /// Show test menu for development
  static void showTestMenu(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Flow Tests'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                testDashboardFlow();
              },
              child: const Text('Test Dashboard Flow'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                testQuickActionVideoFlow();
              },
              child: const Text('Test Video Quick Action'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                testQuickActionClinicFlow();
              },
              child: const Text('Test Clinic Quick Action'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                testSpecializationFlow();
              },
              child: const Text('Test Specialization Flow'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                testDoctorProfileFlow();
              },
              child: const Text('Test Doctor Profile Flow'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}