enum AppointmentStatus {
  pending,
  confirmed,
  completed,
  cancelled,
  expired,
  inProgress,
  unknown;

  static AppointmentStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return AppointmentStatus.pending;
      case 'confirmed':
        return AppointmentStatus.confirmed;
      case 'completed':
        return AppointmentStatus.completed;
      case 'cancelled':
      case 'canceled':
        return AppointmentStatus.cancelled;
      case 'expired':
        return AppointmentStatus.expired;
      case 'in_progress':
      case 'inprogress':
      case 'in-progress':
        return AppointmentStatus.inProgress;
      default:
        return AppointmentStatus.unknown;
    }
  }

  String get displayName {
    switch (this) {
      case AppointmentStatus.pending:
        return 'Pending';
      case AppointmentStatus.confirmed:
        return 'Confirmed';
      case AppointmentStatus.completed:
        return 'Completed';
      case AppointmentStatus.cancelled:
        return 'Cancelled';
      case AppointmentStatus.expired:
        return 'Expired';
      case AppointmentStatus.inProgress:
        return 'In Progress';
      case AppointmentStatus.unknown:
        return 'Unknown';
    }
  }
}

