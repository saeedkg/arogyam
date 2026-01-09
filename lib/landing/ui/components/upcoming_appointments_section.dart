import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../_shared/ui/app_colors.dart';
import '../../../_shared/utils/date_time_formatter.dart';
import '../../../_shared/routing/routing.dart';
import '../../../consultation_pending/ui/pending_consultation_screen.dart';
import '../../entities/dashboard_data.dart';

class UpcomingAppointmentsSection extends StatelessWidget {
  final List<UpcomingAppointment> appointments;

  const UpcomingAppointmentsSection({
    super.key,
    required this.appointments,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return const SizedBox.shrink();
    }

    // Show the most urgent appointment (today's or next upcoming)
    final mostUrgentAppointment = _getMostUrgentAppointment();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryGreen.withOpacity(0.1),
            AppColors.primaryBlue.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primaryGreen.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (appointments.length == 1) {
              // Navigate to single appointment
              Get.to(() => PendingConsultationScreen(
                appointmentId: mostUrgentAppointment.id.toString()
              ));
            } else {
              // Navigate to appointments list
              Get.toNamed('/appointments');
            }
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header with icon and count
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryGreen,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.calendar_today_rounded,
                        color: Colors.white,
                        size: 16,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointments.length == 1 
                                ? 'Upcoming Appointment'
                                : 'Upcoming Appointments',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.grey800,
                            ),
                          ),
                          if (appointments.length > 1)
                            Text(
                              '${appointments.length} appointments scheduled',
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.grey600,
                              ),
                            ),
                        ],
                      ),
                    ),
                    if (appointments.length > 1)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${appointments.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_ios_rounded,
                      size: 16,
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Most urgent appointment details
                _UrgentAppointmentCard(appointment: mostUrgentAppointment),
                
                // Show additional appointments if more than 1
                if (appointments.length > 1) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.primaryGreen.withOpacity(0.2),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.more_horiz_rounded,
                          color: AppColors.primaryGreen,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${appointments.length - 1} more appointment${appointments.length > 2 ? 's' : ''}',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          'Tap to view all',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  UpcomingAppointment _getMostUrgentAppointment() {
    // Sort appointments by date and return the most urgent one
    final sortedAppointments = List<UpcomingAppointment>.from(appointments);
    sortedAppointments.sort((a, b) => a.scheduledAt.compareTo(b.scheduledAt));
    
    // Prioritize today's appointments
    final now = DateTime.now();
    final todayAppointments = sortedAppointments.where((apt) {
      return apt.scheduledAt.year == now.year &&
             apt.scheduledAt.month == now.month &&
             apt.scheduledAt.day == now.day;
    }).toList();
    
    if (todayAppointments.isNotEmpty) {
      return todayAppointments.first;
    }
    
    return sortedAppointments.first;
  }
}

class _UrgentAppointmentCard extends StatelessWidget {
  final UpcomingAppointment appointment;

  const _UrgentAppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    final isToday = _isToday(appointment.scheduledAt);
    final isTomorrow = _isTomorrow(appointment.scheduledAt);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isToday 
              ? AppColors.primaryGreen.withOpacity(0.3)
              : AppColors.grey200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Doctor Avatar
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isToday 
                    ? AppColors.primaryGreen.withOpacity(0.4)
                    : AppColors.grey300,
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 20,
              backgroundImage: appointment.doctorImage != null
                  ? NetworkImage(appointment.doctorImage!)
                  : null,
              backgroundColor: AppColors.primaryGreen.withOpacity(0.1),
              child: appointment.doctorImage == null
                  ? Icon(
                      Icons.person,
                      color: AppColors.primaryGreen,
                      size: 20,
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 12),
          
          // Appointment Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Doctor Name and Status
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        appointment.doctorName,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: isToday 
                              ? AppColors.primaryGreen 
                              : AppColors.grey800,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: _getStatusColor(appointment.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        _getStatusText(appointment.status),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: _getStatusColor(appointment.status),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                
                // Date and Time Row
                Row(
                  children: [
                    // Date with special styling for today/tomorrow
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isToday 
                            ? AppColors.primaryGreen.withOpacity(0.1)
                            : isTomorrow
                                ? AppColors.primaryBlue.withOpacity(0.1)
                                : AppColors.grey100,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isToday 
                            ? 'Today' 
                            : isTomorrow 
                                ? 'Tomorrow'
                                : DateTimeFormatter.formatDateShort(appointment.scheduledAt),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: isToday 
                              ? AppColors.primaryGreen 
                              : isTomorrow
                                  ? AppColors.primaryBlue
                                  : AppColors.grey700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Time
                    Text(
                      DateTimeFormatter.formatTime(appointment.scheduledAt),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.grey700,
                      ),
                    ),
                    const Spacer(),
                    // Type Icon
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: (appointment.type == 'online' 
                            ? AppColors.primaryBlue 
                            : AppColors.primaryGreen).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Icon(
                        appointment.type == 'online' 
                            ? Icons.video_call_rounded 
                            : Icons.location_on_rounded,
                        size: 14,
                        color: appointment.type == 'online' 
                            ? AppColors.primaryBlue 
                            : AppColors.primaryGreen,
                      ),
                    ),
                  ],
                ),
                
                // Patient Info (if not self)
                if (appointment.patientType != 'self') ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'For ${appointment.patientName}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppColors.grey600,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && 
           date.month == now.month && 
           date.day == now.day;
  }

  bool _isTomorrow(DateTime date) {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return date.year == tomorrow.year && 
           date.month == tomorrow.month && 
           date.day == tomorrow.day;
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return AppColors.primaryGreen;
      case 'pending':
        return AppColors.warningOrange;
      case 'cancelled':
        return AppColors.errorRed;
      default:
        return AppColors.grey500;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return 'Confirmed';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status;
    }
  }
}