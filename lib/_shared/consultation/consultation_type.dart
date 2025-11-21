import 'package:flutter/material.dart';

/// Enum representing the appointment type (clinic or video consultation)
enum AppointmentType {
  clinic,
  video;

  /// Returns the display name for the appointment type
  String get displayName {
    switch (this) {
      case AppointmentType.clinic:
        return 'Clinic Appointment';
      case AppointmentType.video:
        return 'Video Consultation';
    }
  }

  /// Returns a brief description for the appointment type
  String get description {
    switch (this) {
      case AppointmentType.clinic:
        return 'Visit doctor at clinic';
      case AppointmentType.video:
        return 'Consult via video call';
    }
  }

  /// Returns the icon for the appointment type
  IconData get icon {
    switch (this) {
      case AppointmentType.clinic:
        return Icons.local_hospital_rounded;
      case AppointmentType.video:
        return Icons.videocam_rounded;
    }
  }
}
